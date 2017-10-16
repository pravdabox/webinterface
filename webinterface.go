package main

import (
	"bytes"
	"database/sql"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"github.com/fsnotify/fsnotify"
	_ "github.com/go-sql-driver/mysql"
	wsd "github.com/joewalnes/websocketd/libwebsocketd"
	"html/template"
	"io"
	"io/ioutil"
	"net"
	"net/http"
	"os"
	"os/exec"
	s "strings"
	"time"
)

const (
	// VERSION holds the version
	VERSION = "0.70.1"

	// MAXFORKS limits the forks of websockets
	MAXFORKS = 10
)

var (
	// flags
	listenAddress = flag.String("l", "127.0.0.1:8080", "Web interface listen address")
	version       = flag.Bool("v", false, "Display version")

	// templates
	templateMap = template.FuncMap{
		"Upper": func(str string) string {
			return s.ToUpper(str)
		},
	}
	templates = template.New("").Funcs(templateMap)

	// make shit shorter
	p = fmt.Println

	// variable for the database
	db *sql.DB

	// my own IP
	myIP string
)

// Model of stuff to render a page
type Model struct {
	Title   string
	Version string
	MyIP    string
}

// Location of an IP
type Location struct {
	IP          string  `json:"ip"`
	CountryName string  `json:"country_name"`
	RegionName  string  `json:"region_name"`
	CityName    string  `json:"city_name"`
	Latitude    float32 `json:"lat"`
	Longitude   float32 `json:"lng"`
}

func init() {
	// Parse all of the bindata templates
	for _, path := range AssetNames() {
		bytes, err := Asset(path)
		if err != nil {
			p("Unable to parse: path=%s, err=%s", path, err)
		}
		templates.New(path).Parse(string(bytes))
	}

	// open mysql connection
	var err error
	db, err = sql.Open("mysql", "ip2location:ip2location@/ip2location")
	if err != nil {
		p(err.Error())
	}

	// validate connection
	err = db.Ping()
	if err != nil {
		p(err.Error())
	}

	// get current public IP
	resp, err := http.Get("http://wtfismyip.com/text")
	if err != nil {
		p(err.Error())
	}
	defer resp.Body.Close()
	r, _ := ioutil.ReadAll(resp.Body)
	myIP = s.TrimSpace(string(r))
}

func main() {
	flag.Parse()

	if *version {
		p(VERSION)
		os.Exit(0)
	}

	go webserver()
	go imagesWatcher()

	// wait indefinitely
	done := make(chan bool)
	<-done
}

func webserver() {
	// staticfiles
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(assetFS())))

	// websocket
	logScope := wsd.RootLogScope(wsd.LogAccess, func(l *wsd.LogScope,
		level wsd.LogLevel, levelName string,
		category string, msg string, args ...interface{}) {
	})
	config := &wsd.Config{
		ScriptDir:      "/opt/pravdabox/filters",
		UsingScriptDir: true,
		StartupTime:    time.Now(),
		DevConsole:     false,
	}
	http.HandleFunc("/ws-bin/", func(rw http.ResponseWriter, req *http.Request) {
		handler := http.StripPrefix("/ws-bin", wsd.NewWebsocketdServer(config, logScope, MAXFORKS))
		handler.ServeHTTP(rw, req)
	})

	// images
	http.Handle("/image/", http.StripPrefix("/image/", http.FileServer(http.Dir("/tmp/driftnet"))))

	// index
	http.HandleFunc("/", func(rw http.ResponseWriter, req *http.Request) {
		model := Model{
			Title:   "Pravdabox",
			Version: VERSION,
			MyIP:    myIP,
		}
		renderTemplate(rw, "templates/index.html", &model)
	})

	// ip2location
	http.HandleFunc("/ip2location", func(rw http.ResponseWriter, req *http.Request) {
		l := new(Location)
		ip := req.URL.Query().Get("ip")
		l.IP = ip
		numIP, _ := ip2long(net.ParseIP(ip))

		row := db.QueryRow("SELECT country_name, region_name, city_name, latitude, longitude FROM ip2location_db5 WHERE ip_from < ? AND ip_to > ? LIMIT 1", numIP, numIP)
		err := row.Scan(&l.CountryName, &l.RegionName, &l.CityName, &l.Latitude, &l.Longitude)
		if err != nil {
			fmt.Fprintf(rw, "{\"error\": \"%s\"}", err.Error())
		} else {
			b := new(bytes.Buffer)
			json.NewEncoder(b).Encode(l)
			io.Copy(rw, b)
		}
	})

	// about
	http.HandleFunc("/about", func(rw http.ResponseWriter, req *http.Request) {
		model := Model{
			Title:   "Pravdabox - About",
			Version: VERSION,
		}
		renderTemplate(rw, "templates/about.html", &model)
	})

	// firmwareupdate
	http.HandleFunc("/firmwareupdate", func(rw http.ResponseWriter, req *http.Request) {
		model := Model{
			Title:   "Pravdabox - Firmwareupdate",
			Version: VERSION,
		}
		renderTemplate(rw, "templates/firmwareupdate.html", &model)
	})

	// firmwareupdate
	http.HandleFunc("/firmwareupdate-run", func(rw http.ResponseWriter, req *http.Request) {
		exec.Command("/usr/sbin/upgrader")
	})

	// upgrade
	http.HandleFunc("/upgrade", func(rw http.ResponseWriter, req *http.Request) {
		model := Model{
			Title:   "Pravdabox - Upgrade your privacy",
			Version: VERSION,
		}
		renderTemplate(rw, "templates/upgrade.html", &model)
	})

	http.ListenAndServe(*listenAddress, nil)
}

func imagesWatcher() {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		p(err.Error())
	}
	defer watcher.Close()

	outfile, err := os.OpenFile("/tmp/filter-images.out", os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0644)
	if err != nil {
		p(err.Error())
	}
	defer outfile.Close()

	go func() {
		for {
			select {
			case event := <-watcher.Events:
				if event.Op&fsnotify.Create == fsnotify.Create {
					filename := s.Replace(event.Name, "/tmp/driftnet/", "", 1)
					if _, err = outfile.WriteString(filename + "\n"); err != nil {
						p("error:", err.Error())
					}
				}
			case err := <-watcher.Errors:
				p("error:", err.Error())
			}
		}
	}()

	err = watcher.Add("/tmp/driftnet")
	if err != nil {
		p(err.Error())
	}

	done := make(chan bool)
	<-done
}

// Render a template given a model
func renderTemplate(w http.ResponseWriter, tmpl string, p interface{}) {
	err := templates.ExecuteTemplate(w, tmpl, p)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// converts an IP to the numerical value of the DB
func ip2long(ip net.IP) (uint32, error) {
	ipByte := ip.To4()
	if ipByte == nil {
		return 0, errors.New("Not an IPv4 address.")
	}
	return uint32(ipByte[0])<<24 | uint32(ipByte[1])<<16 | uint32(ipByte[2])<<8 | uint32(ipByte[3]), nil
}

package main

import (
	"flag"
	"fmt"
	"github.com/fsnotify/fsnotify"
	wsd "github.com/joewalnes/websocketd/libwebsocketd"
	"html/template"
	"net/http"
	"os"
	"os/exec"
	s "strings"
	"time"
)

const (
	// VERSION holds the version
	VERSION = "0.11.0"

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
)

// Model of stuff to render a page
type Model struct {
	Title string
}

// Parse all of the bindata templates
func init() {
	for _, path := range AssetNames() {
		bytes, err := Asset(path)
		if err != nil {
			p("Unable to parse: path=%s, err=%s", path, err)
		}
		templates.New(path).Parse(string(bytes))
	}
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
		p(args...)
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
			Title: "Pravdabox",
		}
		renderTemplate(rw, "templates/index.html", &model)
	})

	// about
	http.HandleFunc("/about", func(rw http.ResponseWriter, req *http.Request) {
		model := Model{
			Title: "Pravdabox - About",
		}
		renderTemplate(rw, "templates/about.html", &model)
	})

	// firmwareupdate
	http.HandleFunc("/firmwareupdate", func(rw http.ResponseWriter, req *http.Request) {
		model := Model{
			Title: "Pravdabox - Firmwareupdate",
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
			Title: "Pravdabox - Upgrade your privacy",
		}
		renderTemplate(rw, "templates/upgrade.html", &model)
	})

	http.ListenAndServe(*listenAddress, nil)
}

func imagesWatcher() {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		p(err)
	}
	defer watcher.Close()

	outfile, err := os.OpenFile("/tmp/filter-images.out", os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0644)
	if err != nil {
		p(err)
	}
	defer outfile.Close()

	go func() {
		for {
			select {
			case event := <-watcher.Events:
				if event.Op&fsnotify.Create == fsnotify.Create {
					filename := s.Replace(event.Name, "/tmp/driftnet/", "", 1)
					if _, err = outfile.WriteString(filename + "\n"); err != nil {
						p("error:", err)
					}
				}
			case err := <-watcher.Errors:
				p("error:", err)
			}
		}
	}()

	err = watcher.Add("/tmp/driftnet")
	if err != nil {
		p(err)
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

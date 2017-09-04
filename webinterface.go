package main

import (
	"flag"
	"fmt"
	"github.com/fsnotify/fsnotify"
	wsd "github.com/joewalnes/websocketd/libwebsocketd"
	"io/ioutil"
	"net/http"
	"os"
	s "strings"
	"time"
)

// make shit shorter
var p = fmt.Println

// VERSION holds the version
const VERSION = "0.8.0"

// MAXFORKS limits the forks of websockets
const MAXFORKS = 10

var (
	listenAddress = flag.String("l", "127.0.0.1:8080", "Web interface listen address")
	version       = flag.Bool("v", false, "Display version")
)

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
	http.Handle("/", http.FileServer(assetFS()))

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

	// image renderer
	http.HandleFunc("/image/", imageRenderer)

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

func imageRenderer(w http.ResponseWriter, r *http.Request) {
	filename := s.Replace(r.URL.String(), "/image/", "", 1)
	dat, _ := ioutil.ReadFile("/tmp/driftnet/" + filename)
	w.Write(dat)
}

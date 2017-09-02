package main

import (
	"flag"
	"fmt"
	"github.com/fsnotify/fsnotify"
	wsd "github.com/joewalnes/websocketd/libwebsocketd"
	"net/http"
	"os"
	"time"
)

// VERSION holds the version
const VERSION = "0.6.0"

// MAXFORKS limits the forks of websockets
const MAXFORKS = 10

var (
	listenAddress   = flag.String("l", "127.0.0.1:8080", "Web interface listen address")
	wsListenAddress = flag.String("wsl", "127.0.0.1:8088", "Web sockets listen address")
	version         = flag.Bool("v", false, "Display version")
)

func main() {
	flag.Parse()

	if *version {
		fmt.Println(VERSION)
		os.Exit(0)
	}

	go webinterface()
	go websockets()
	go imagesWatcher()

	// wait indefinitely
	done := make(chan bool)
	<-done
}

func webinterface() {
	http.Handle("/", http.FileServer(assetFS()))
	http.ListenAndServe(*listenAddress, nil)
}

func websockets() {
	// A log scope allows you to customize the logging that websocketd performs.
	//You can provide your own log scope with a log func.
	logScope := wsd.RootLogScope(wsd.LogAccess, func(l *wsd.LogScope,
		level wsd.LogLevel, levelName string,
		category string, msg string, args ...interface{}) {
		fmt.Println(args...)
	})

	// Configuration options tell websocketd where to look for programs to
	// run as WebSockets.
	config := &wsd.Config{
		ScriptDir:      "/opt/pravdabox/filters",
		UsingScriptDir: true,
		StartupTime:    time.Now(),
		DevConsole:     false,
	}

	// Register your route and handler.
	http.HandleFunc("/ws-bin/", func(rw http.ResponseWriter, req *http.Request) {
		handler := http.StripPrefix("/ws-bin", wsd.NewWebsocketdServer(config, logScope, MAXFORKS))
		handler.ServeHTTP(rw, req)
	})
	if err := http.ListenAndServe(*wsListenAddress, nil); err != nil {
		fmt.Println("could not start server!", err)
		os.Exit(1)
	}
}

func imagesWatcher() {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		fmt.Println(err)
	}
	defer watcher.Close()

	go func() {
		for {
			select {
			case event := <-watcher.Events:
				fmt.Println("event:", event)
				if event.Op&fsnotify.Write == fsnotify.Write {
					fmt.Println("modified file:", event.Name)
				}
			case err := <-watcher.Errors:
				fmt.Println("error:", err)
			}
		}
	}()

	err = watcher.Add("/tmp/driftnet")
	if err != nil {
		fmt.Println(err)
	}

	done := make(chan bool)
	<-done
}

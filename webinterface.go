package main

import (
	"flag"
	"fmt"
	wsd "github.com/joewalnes/websocketd/libwebsocketd"
	"net/http"
	"os"
	"time"
)

// VERSION holds the version
const VERSION = "0.4.2"

// MAXFORKS limits the forks of websockets
const MAXFORKS = 10

var (
	listenAddress = flag.String("l", "127.0.0.1:8080", "Web interface listen address")
	version       = flag.Bool("v", false, "Display version")
)

func main() {
	flag.Parse()

	if *version {
		fmt.Println(VERSION)
		os.Exit(0)
	}

	go webinterface()
	go websockets()

	// wait indefinitely
	wait := make(chan string)
	<-wait
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
	if err := http.ListenAndServe(fmt.Sprintf(":%d", 8088), nil); err != nil {
		fmt.Println("could not start server!", err)
		os.Exit(1)
	}
}

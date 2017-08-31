package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
)

// VERSION holds the version
const VERSION = "0.1.0"

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

	http.Handle("/", http.FileServer(assetFS()))

	http.ListenAndServe(*listenAddress, nil)
}

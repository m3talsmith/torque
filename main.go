package main

import (
	"log"
	"net/http"

	"github.com/m3talsmith/torque/databus"
)

func main() {
	log.SetFlags(log.Lshortfile)

	// websocket server
	server := databus.NewServer("/entry")
	go server.Listen()

	// static files
	http.Handle("/", http.FileServer(http.Dir("static")))

	log.Fatal(http.ListenAndServe(":8080", nil))
}

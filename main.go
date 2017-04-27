package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

var clients map[time.Time]*websocket.Conn

var port string

func init() {
	// Set port if it's passed through the cli
	flag.StringVar(&port, "port", "3000", "the websocket port")
	flag.Parse()

	// Overide port if it's already set as a system environment variable
	if env := os.Getenv("TORQUE_PORT"); env != "" {
		port = env
	}

	clients = make(map[time.Time]*websocket.Conn)
}

// Broadcast message to everyone connected
func broadcast(senderID time.Time, msgType int, msg []byte) {
	for clientID, client := range clients {
		if clientID == senderID {
			continue
		}

		if err := client.WriteMessage(msgType, msg); err != nil {
			fmt.Println(err)
			return
		}
	}
}

func main() {
	http.HandleFunc("/messages", func(w http.ResponseWriter, r *http.Request) {
		ws, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			fmt.Println(err)
			return
		}

		clientID := time.Now()
		clients[clientID] = ws
		fmt.Printf("client %v connected: %d clients online\n", clientID, len(clients))

		for {
			msgType, msg, err := ws.ReadMessage()
			if err != nil {
				fmt.Println(err)

				delete(clients, clientID)
				fmt.Printf("client %v disconnected: %d clients online\n", clientID, len(clients))

				return
			}
			broadcast(clientID, msgType, msg)
		}
	})

	http.Handle("/", http.FileServer(http.Dir("static")))

	fmt.Println("Websocket started at: localhost:3000")
	err := http.ListenAndServe(":3000", nil)
	if err != nil {
		panic(err)
	}
}

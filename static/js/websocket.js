var ws = new WebSocket("ws://localhost:8080/entry")
ws.onopen = function(e) {
    console.log("connected to server")
}
ws.onmessage = function(e) {
    console.log("recieved:", e.data)
}
ws.onclose = function(e) {
    console.log("disconnected from server")
}
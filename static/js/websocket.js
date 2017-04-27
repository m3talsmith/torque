var ws = new WebSocket("ws://localhost:3000/messages")
ws.onopen = function(e) {
    console.log("connected to server")
}
ws.onmessage = function(e) {
    console.log(e.data)
}
ws.onclose = function(e) {
    console.log("disconnected from server")
}
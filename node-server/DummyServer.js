var express = require('express');
var io = require('socket.io');
var app = express();               
var server = app.listen(8080);
var socketServer = io(server);     

socketServer.on('connection', openSocket);

function openSocket(socket){
  console.log('new user address: ' + socket.handshake.address);
  socket.emit('message', 'Hello, ' + socket.handshake.address);
  var i = 0;
  setInterval(function() { 
    i = i + 1;
    socket.emit('message', i);
  }, 500);
}

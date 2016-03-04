var express = require('express');
var io = require('socket.io');
var app = express();               
var server = app.listen(8080);
var socketServer = io(server);     

var serialport = require('serialport');
var SerialPort  = serialport.SerialPort;
var portName = process.argv[2];
var portConfig = {
  baudRate: 9600,
  parser: serialport.parsers.readline('\n')
};

var myPort = new SerialPort(portName, portConfig);

socketServer.on('connection', openSocket);

function openSocket(socket){
  console.log('new user address: ' + socket.handshake.address);
  socket.emit('message', 'Hello, ' + socket.handshake.address);
  myPort.on('data', function(data) {
    socket.emit('message', data);
  });
}

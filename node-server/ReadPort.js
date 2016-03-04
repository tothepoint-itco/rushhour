var serialport = require("serialport");
var SerialPort = serialport.SerialPort;

var serialPort = new SerialPort("/dev/cu.usbmodem1421", {
  baudrate: 9600,
  parser: serialport.parsers.readline("\n")
});

serialPort.on("open", function () {
  console.log('open');
  serialPort.on('data', function(data) {
    console.log(data);
  });
});


# Rush Hour IoT

This document is an attempt to write down some of the thoughts, design decisions, work etc. that has been done so far.
The primary goal so far has been to *shoot a tracer bullet*, that is to illustrate a working concept end-to-end: from reading a physical board to visualizing a Rush Hour game board.

To get an idea of the functional scope, you can have a look at the Basecamp project.

This initial set-up consists of three modules that correspond to the architectural layering:
*elm-client → node-server → arduino (⤏ el board)*.


## arduino

This module contains the software to deploy & run on an Arduino.
It reads the physical board and continuously sends the most current reading down a serial link.

The serial wire-protocol still needs to be designed.
A first version could simply consist of a stream of 36 bits.

```
<stream>     ::=  <packet><stream>|[end-of-stream]
<packet>     ::=  [bit]{36}[end-of-packet]
```

Each bit represents the closing of a magnetic switch (a reed contact) on the physical board.
The order of the bits in a packet corresponds to a left-to-right, top-to-bottom readout of the board.


## node-server

This module consists of a collection of Node.js scripts.
So far, it has only been tested with Node.js version `4.1.1`.

Currently this layer is rather empty.
It just relays a stream of data received over a serial link to a web socket.
That is, it makes the Arduino readings directly available to the Elm client.

Eventually, maybe, to be replaced by Play server.
This server could then take on additional responsibilities, such as infering car locations, keeping score, analytics, ...

Some of the most important scripts to get started are:

* To simulate the output of an Arduino - this will simply run a predefined simulation:

```
cd node-server
node SimulationLevel1.js
```

* To relay the input of a serial link to a websocket (check the sources and associated scripts to tweak which serial port to use):

```
cd node-server
node SerialServer.js
```


## elm-client

This modules consists of an Elm application.

So far I have only ran this using elm-reactor:

```
cd elm-client
elm-reactor
```

And then open [http://localhost:8000/Main.elm?debug](http://localhost:8000/Main.elm?debug).

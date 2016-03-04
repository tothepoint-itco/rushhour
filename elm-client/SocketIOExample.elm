import Graphics.Element exposing (show)
import Task exposing (Task, andThen)
import SocketIO

socket : Task x SocketIO.Socket
socket = SocketIO.io "http://localhost:8080" SocketIO.defaultOptions

received : Signal.Mailbox String
received = Signal.mailbox ""

port responses : Task x ()
port responses = socket `andThen` SocketIO.on "" received.address

main = Signal.map show received.signal
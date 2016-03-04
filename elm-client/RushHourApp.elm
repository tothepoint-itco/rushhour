import Color
import Dict exposing (toList)
import Effects exposing (Never, Effects)
import Graphics.Collage as Collage
import Graphics.Element as Element
import Html exposing (Html, div, text, fromElement, h1)
import Html.Attributes exposing (style)
import SensedBoard exposing (Position, SensedBoard, empty, fromReading, boardSize)
import SocketIO
import StartApp
import Task exposing (Task, andThen)


socketUrl = "http://localhost:8080"
eventName = ""


type alias Model =
  { rawReading : String
  , sensedBoard : SensedBoard
  , history : List (String)
  }


type Action
  = ConnectedToSerialPort String
  | Received String
  | Hint


initModel : Model
initModel =
  { rawReading = ""
  , sensedBoard = SensedBoard.empty
  , history = []
  }


initEffects : Effects Action
initEffects =
  SocketIO.io socketUrl SocketIO.defaultOptions
  `andThen` SocketIO.on eventName socketIOMailbox.address
  |> Task.map (always (ConnectedToSerialPort socketUrl))
  |> Effects.task


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    ConnectedToSerialPort msg ->
      ( model
      , Effects.none
      )
    Received reading ->
      ( { model
        | rawReading = reading
        , sensedBoard = SensedBoard.fromReading reading
        , history = reading :: model.history
        }
      , Effects.none
      )
    Hint ->
      ( model
      , Effects.none
      )


view : Signal.Address Action -> Model -> Html
view address model =
  div
  [ style
    [ "padding" => "20px"
    ]
  ]
  [ div
    [ style
      [ "margin" => "auto"
      , "width" => "200px"
      ]
    ]
    [ renderGrid model.sensedBoard |> fromElement
    ]
  , h1 [] [ text "History" ]
  , renderHistory model.history |> fromElement
  ]


(=>) : a -> b -> (a, b)
(=>) = (,)


cellSide = 25
boardSide = boardSize * cellSide


renderAt : Position -> (Float, Float) -> Collage.Form -> Collage.Form
renderAt (row, column) (w, h) =
  let
    x = column * cellSide
    y = (boardSize - row - 1) * cellSide
  in
    Collage.move ( toFloat(x) - (boardSide - w) / 2
                 , toFloat(y) - (boardSide - h) / 2)


renderClosedSwitchAt : Position -> Collage.Form
renderClosedSwitchAt cell =
  let
    radius = cellSide / 2.5
  in
    Collage.circle radius
    |> Collage.outlined (Collage.solid Color.black)
    |> renderAt cell (cellSide, cellSide)


renderGrid : SensedBoard -> Element.Element
renderGrid sensedBoard =
  Dict.toList sensedBoard
  |> List.filter (\(_, covered) -> covered)
  |> List.map (\(cell, _) -> renderClosedSwitchAt cell)
  |> Collage.collage boardSide boardSide


scaleElement : Float -> Element.Element -> Element.Element
scaleElement scale element =
  let
    (w, h) = (Element.widthOf element, Element.heightOf element)
    (w', h') = (round (toFloat(w) * scale), round (toFloat(h) * scale))
    singleton a = [a]
  in
    element
    |> Collage.toForm
    |> Collage.scale scale
    |> singleton
    |> Collage.collage w' h'


renderHistory : List (String) -> Element.Element
renderHistory history =
  let
    withSensedBoard =
      List.map (\rawReading -> (rawReading, fromReading rawReading))

    withTimestamp =
      List.reverse >> List.indexedMap (,) >> List.reverse

    history' =
      history |> withSensedBoard |> withTimestamp

    historyLine (t, (rawReading, sensedBoard)) =
      [ Element.show ("t" ++ toString(t) ++ " - rawReading=" ++ rawReading)
      , renderGrid sensedBoard |> scaleElement 0.5
      , Element.spacer 10 10
      ]
  in
    List.concatMap historyLine history'
    |> Element.flow Element.down


{-
  Mailbox used by SocketIO to deliver received payloads.
  This mailbox will generate in input signal into the application.
-}
socketIOMailbox : Signal.Mailbox String
socketIOMailbox = Signal.mailbox ""

inputs : List (Signal Action)
inputs = [ Signal.map Received socketIOMailbox.signal ]



{-
  StartApp's Config
  type alias Config model action =
    { init : (model, Effects action)
    , update : action -> model -> (model, Effects action)
    , view : Signal.Address action -> model -> Html
    , inputs : List (Signal.Signal action)
    }
-}
appConfig : StartApp.Config Model Action
appConfig =
  { init = (initModel, initEffects)
  , update = update
  , view = view
  , inputs = inputs
  }


{-
  StartApp's App
  type alias App model =
    { html : Signal Html
    , model : Signal model
    , tasks : Signal (Task.Task Never ())
    }
-}
app : StartApp.App Model
app =
  StartApp.start appConfig



{-
  Finally we hook the view and ports up with the Elm runtime.
-}

main : Signal Html
main =
  app.html


port tasks : Signal (Task Never ())
port tasks =
  app.tasks

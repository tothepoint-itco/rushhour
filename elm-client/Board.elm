
module Board where

import Dict exposing (Dict)
import SensedBoard exposing (Position)



type alias Size =
  Int


type Orientation
  = Horizontal
  | Vertical


type alias Car =
  { size: Size
  , color: Color
  , orientation: Orientation
  }


type Action
  = PutCar { car: Car, at: Position }
  | MoveCar { from: Position, to: Position }


type alias Board =
  Dict Position Car



--emptyBoard width height =
--  { dimension: (width,height)
--  , cars: []
--  }
--
--
--applyAction : Action -> Board -> Maybe Board
--applyAction action board =
--  let
--    (w,h) = board.dimension
--  in
--    case action of
--      PutCar {size, position, direction}North ->
--        if (y + 1 < size) || (y + 1 > h)
--        then None
--        else Some ((w, h), { board | cars <- (size, (x, y), North) :: cars)
--
--      PutCar size (x, y) East ->
--      PutCar size (x, y) South ->
--      PutCar size (x, y) West ->
--      MoveCar (x0, y0) (x1, y1) ->
--      ExitCar (x, y) ->


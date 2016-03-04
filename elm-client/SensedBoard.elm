
module SensedBoard where

import Dict exposing (Dict)
import String exposing (toList)



type alias Position =
  (Int, Int)


type alias SensedBoard =
  Dict Position Bool


boardSize = 6


empty : SensedBoard
empty =
  mkSensedBoard <| List.repeat (boardSize ^ 2) False


fromReading : String -> SensedBoard
fromReading =
  String.toList >> List.map charToBool >> mkSensedBoard


mkSensedBoard : List Bool -> SensedBoard
mkSensedBoard =
  zip positionsInRowMajorOrder >> Dict.fromList


positionsInRowMajorOrder : List Position
positionsInRowMajorOrder =
  let
    idx = [0..boardSize-1]
  in
    product idx idx


{-
  utils
-}

charToBool : Char -> Bool
charToBool c =
  List.member c ['1', 'T', 't']


zip : List a -> List b -> List (a, b)
zip =
  List.map2 (,)


product : List a -> List b -> List (a, b)
product =
  liftA2 (,)


liftA2 : (a -> b -> c) -> List a -> List b -> List c
liftA2 f xs ys =
  xs |> List.concatMap (\x ->
    ys |> List.map (\y -> f x y))


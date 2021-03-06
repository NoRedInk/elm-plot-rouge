module Histogram exposing (main, plane, testScores)

import Internal.Colors exposing (..)
import Svg exposing (Svg, circle, g, svg, text, text_)
import Svg.Attributes exposing (fill, height, r, stroke, transform, width)
import Svg.Coordinates exposing (..)
import Svg.Plot exposing (..)


plane : Plane
plane =
    { x =
        { marginLower = 10
        , marginUpper = 10
        , length = 300
        , min = 23
        , max = 44
        }
    , y =
        { marginLower = 10
        , marginUpper = 10
        , length = 300
        , min = 0
        , max = 10
        }
    }


testScores : Histogram msg
testScores =
    { bars = List.map (Bar [ stroke blueStroke, fill blueFill ]) [ 1, 2, 3, 6, 8, 9, 6, 4, 2, 1 ]
    , interval = 2.1
    , intervalBegin = 23
    }


main : Svg msg
main =
    svg
        [ width (String.fromFloat plane.x.length)
        , height (String.fromFloat plane.y.length)
        ]
        [ histogram plane testScores
        , fullHorizontal plane [] 0
        , fullVertical plane [] 23
        , xTicks plane 5 [] 0 [ 24, 26, 30 ]
        , yTicks plane 5 [] 23 [ 1, 2, 3 ]
        ]

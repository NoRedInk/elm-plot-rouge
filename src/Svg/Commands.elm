module Svg.Commands exposing (Command(..), description)

{-| SVG path commands.
-}

import Svg.Coordinates exposing (Plane, Point, toSVGX, toSVGY)


{-| -}
type Command
    = Move Float Float
    | Line Float Float
    | CubicBeziers Float Float Float Float Float Float
    | CubicBeziersShort Float Float Float Float
    | QuadraticBeziers Float Float Float Float
    | QuadraticBeziersShort Float Float
    | Arc Float Float Bool Bool Bool Float Float
    | Close


{-| -}
description : Plane -> List Command -> String
description plane commands =
    joinCommands (List.map (translate plane >> stringCommand) commands)


translate : Plane -> Command -> Command
translate plane command =
    case command of
        Move x y ->
            Move (toSVGX plane x) (toSVGY plane y)

        Line x y ->
            Line (toSVGX plane x) (toSVGY plane y)

        CubicBeziers cx1 cy1 cx2 cy2 x y ->
            CubicBeziers (toSVGX plane cx1) (toSVGY plane cy1) (toSVGX plane cx2) (toSVGY plane cy2) (toSVGX plane x) (toSVGY plane y)

        CubicBeziersShort cx1 cy1 x y ->
            CubicBeziersShort (toSVGX plane cx1) (toSVGY plane cy1) (toSVGX plane x) (toSVGY plane y)

        QuadraticBeziers cx1 cy1 x y ->
            QuadraticBeziers (toSVGX plane cx1) (toSVGY plane cy1) (toSVGX plane x) (toSVGY plane y)

        QuadraticBeziersShort x y ->
            QuadraticBeziersShort (toSVGX plane x) (toSVGY plane y)

        Arc rx ry xAxisRotation largeArcFlag sweepFlag x y ->
            Arc (toSVGX plane rx) (toSVGY plane ry) xAxisRotation largeArcFlag sweepFlag (toSVGX plane x) (toSVGY plane y)

        Close ->
            Close


stringCommand : Command -> String
stringCommand command =
    case command of
        Move x y ->
            "M" ++ stringPoint (Point x y)

        Line x y ->
            "L" ++ stringPoint (Point x y)

        CubicBeziers cx1 cy1 cx2 cy2 x y ->
            "C" ++ stringPoints [ Point cx1 cy1, Point cx2 cy2, Point x y ]

        CubicBeziersShort cx1 cy1 x y ->
            "Q" ++ stringPoints [ Point cx1 cy1, Point x y ]

        QuadraticBeziers cx1 cy1 x y ->
            "Q" ++ stringPoints [ Point cx1 cy1, Point x y ]

        QuadraticBeziersShort x y ->
            "T" ++ stringPoint (Point x y)

        Arc rx ry xAxisRotation largeArcFlag sweepFlag x y ->
            "A"
                ++ joinCommands
                    [ stringPoint (Point rx ry)
                    , stringBool xAxisRotation
                    , stringBoolInt largeArcFlag
                    , stringBoolInt sweepFlag
                    , stringPoint (Point x y)
                    ]

        Close ->
            "Z"


joinCommands : List String -> String
joinCommands commands =
    String.join " " commands


stringPoint : Point -> String
stringPoint { x, y } =
    String.fromFloat x ++ " " ++ String.fromFloat y


stringPoints : List Point -> String
stringPoints points =
    String.join "," (List.map stringPoint points)


stringBoolInt : Bool -> String
stringBoolInt bool =
    if bool then
        "0"

    else
        "1"


stringBool : Bool -> String
stringBool bool =
    if bool then
        "True"

    else
        "False"

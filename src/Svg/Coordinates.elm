module Svg.Coordinates exposing
    ( Plane, Axis
    , minimum, maximum
    , toSVGX, toSVGY, scaleSVG
    , toCartesianX, toCartesianY, scaleCartesian
    , Point, place, placeWithOffset
    )

{-| _Disclaimer:_ If you're looking for a plotting library, then please
use [elm-plot](https://github.com/terezka/elm-plot) instead, as this library is not
made to be user friendly. If you feel like you're missing something in elm-plot,
you're welcome to open an issue in the repo and I'll see what I can do
to accommodate your needs!

---

This module contains helpers for cartesian/SVG coordinate translation.


# Plane

@docs Plane, Axis


# Plane from data

You may want to produce a plane which fits all your data. For that you need
to find the minimum and maximum values withing your data in order to calculate
the domain and range.

@docs minimum, maximum

    planeFromPoints : List Point -> Plane
    planeFromPoints points =
        { x =
            { marginLower = 10
            , marginUpper = 10
            , length = 300
            , min = minimum .x points
            , max = maximum .x points
            }
        , y =
            { marginLower = 10
            , marginUpper = 10
            , length = 300
            , min = minimum .y points
            , max = maximum .y points
            }
        }


# Cartesian to SVG

@docs toSVGX, toSVGY, scaleSVG


# SVG to cartesian

@docs toCartesianX, toCartesianY, scaleCartesian


# Helpers

@docs Point, place, placeWithOffset

-}

import Svg exposing (Attribute)
import Svg.Attributes exposing (transform)



-- Plane


{-| The properties of your plane.
-}
type alias Plane =
    { x : Axis
    , y : Axis
    }


{-| The axis of the plane.

  - The margin properties are the upper and lower margins for the axis. So for example,
    if you want to add margin on top of the plot, increase the marginUpper of
    the y-`Axis`.
  - The length is the length of your SVG axis. (`plane.x.length` is the width,
    `plane.y.length` is the height)
  - The `min` and `max` values is the reach of your plane. (Domain for the y-axis, range
    for the x-axis)

-}
type alias Axis =
    { marginLower : Float
    , marginUpper : Float
    , length : Float
    , min : Float
    , max : Float
    }


{-| Helper to extract the minimum value amongst your coordinates.
-}
minimum : (a -> Float) -> List a -> Float
minimum toValue =
    List.map toValue
        >> List.minimum
        >> Maybe.withDefault 0


{-| Helper to extract the maximum value amongst your coordinates.
-}
maximum : (a -> Float) -> List a -> Float
maximum toValue =
    List.map toValue
        >> List.maximum
        >> Maybe.withDefault 1



-- TRANSLATION


{-| For scaling a cartesian value to a SVG value. Note that this will _not_
return a coordinate on the plane, but the scaled value.
-}
scaleSVG : Axis -> Float -> Float
scaleSVG axis value =
    value * innerLength axis / range axis


{-| Translate a SVG x-coordinate to its cartesian x-coordinate.
-}
toSVGX : Plane -> Float -> Float
toSVGX plane value =
    scaleSVG plane.x (value - plane.x.min) + plane.x.marginLower


{-| Translate a SVG y-coordinate to its cartesian y-coordinate.
-}
toSVGY : Plane -> Float -> Float
toSVGY plane value =
    scaleSVG plane.y (plane.y.max - value) + plane.y.marginLower


{-| For scaling a SVG value to a cartesian value. Note that this will _not_
return a coordinate on the plane, but the scaled value.
-}
scaleCartesian : Axis -> Float -> Float
scaleCartesian axis value =
    value * range axis / innerLength axis


{-| Translate a cartesian x-coordinate to its SVG x-coordinate.
-}
toCartesianX : Plane -> Float -> Float
toCartesianX plane value =
    scaleCartesian plane.x (value - plane.x.marginLower) + plane.x.min


{-| Translate a cartesian y-coordinate to its SVG y-coordinate.
-}
toCartesianY : Plane -> Float -> Float
toCartesianY plane value =
    range plane.y - scaleCartesian plane.y (value - plane.y.marginLower) + plane.y.min



-- PLACING HELPERS


{-| Representation of a point in your plane.
-}
type alias Point =
    { x : Float
    , y : Float
    }


{-| A `transform translate(x, y)` SVG attribute. Beware that using this and
and another transform attribute on the same node, will overwrite the first.
If that's the case, just make one yourself:

    myTransformAttribute : Svg.Attribute msg
    myTransformAttribute =
        transform <|
            "translate("
                ++ String.fromFloat (toSVGX plane x)
                ++ ","
                ++ String.fromFloat (toSVGY plane y)
                ++ ") "
                ++ "rotateX("
                ++ whatever
                ++ ")"

-}
place : Plane -> Point -> Attribute msg
place plane point =
    placeWithOffset plane point 0 0


{-| Place at coordinate, but you may add a SVG offset. See `place` above for important notes.
-}
placeWithOffset : Plane -> Point -> Float -> Float -> Attribute msg
placeWithOffset plane { x, y } offsetX offsetY =
    transform ("translate(" ++ String.fromFloat (toSVGX plane x + offsetX) ++ "," ++ String.fromFloat (toSVGY plane y + offsetY) ++ ")")



-- INTERNAL HELPERS


range : Axis -> Float
range axis =
    let
        diff =
            axis.max - axis.min
    in
    if diff > 0 then
        diff

    else
        1


innerLength : Axis -> Float
innerLength axis =
    Basics.max 1 (axis.length - axis.marginLower - axis.marginUpper)

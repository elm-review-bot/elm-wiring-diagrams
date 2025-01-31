module WiringDiagram.Svg exposing
    ( view, Viewport, layoutToSvg, diagramToSvg
    , smallViewport, mediumViewport, wideViewport, largeViewport
    , SvgConfig, layoutToSvgWithConfig
    )

{-| Convert a Layout of a WireDiagram to SVG

@docs view, Viewport, layoutToSvg, diagramToSvg


## Viewport defaults

@docs smallViewport, mediumViewport, wideViewport, largeViewport


# Customization

@docs SvgConfig, layoutToSvgWithConfig

-}

import Html exposing (Html)
import Svg exposing (Svg, svg)
import Svg.Attributes exposing (..)
import WiringDiagram exposing (..)
import WiringDiagram.Layout exposing (..)
import WiringDiagram.Layout.Box exposing (..)
import WiringDiagram.Svg.Arrow exposing (arrow)


{-| Placement and dimensions of a Viewport to render SVG inside
-}
type alias Viewport =
    { width : Float
    , height : Float
    , xMin : Float
    , yMin : Float
    }


{-| Render a list of Svg items in a viewport to Html
-}
view : Viewport -> List (Svg msg) -> Html msg
view vp svgItems =
    let
        w =
            String.fromFloat vp.width

        h =
            String.fromFloat vp.height
    in
    svg
        [ width w
        , height h
        , viewBox <| "0 0 " ++ w ++ " " ++ h
        ]
        svgItems


{-| Preliminary way to control how labels turn into String for SVG
-}
type alias SvgConfig a =
    { toLabelString : a -> String
    , dummy : ()
    }


{-| Render a Layout to Svg
-}
layoutToSvg : Layout b -> Svg msg
layoutToSvg =
    layoutToSvgWithConfig
        { toLabelString = always "_", dummy = () }


toSvgTransform : { a | x : Float, y : Float } -> Svg.Attribute msg
toSvgTransform t =
    transform <|
        "translate("
            ++ String.fromFloat t.x
            ++ ","
            ++ String.fromFloat t.y
            ++ ")"


{-| Render a Layout to Svg with configurable labeling
-}
layoutToSvgWithConfig : SvgConfig a -> Layout a -> Svg msg
layoutToSvgWithConfig svgConfig l =
    case l of
        Group g ->
            let
                tx =
                    toSvgTransform g.transform

                itx =
                    toSvgTransform g.interiorTransform

                inner =
                    Svg.g [ itx ] <|
                        List.map layoutToSvg g.interior
            in
            case g.exterior of
                Just b ->
                    Svg.g [ tx ] <|
                        [ box svgConfig b, inner ]

                _ ->
                    inner

        Item b ->
            box svgConfig b

        Arrow arr ->
            arrow arr


{-| Shortcut render a Diagram (via Layout) to Svg
-}
diagramToSvg : Diagram a -> Svg msg
diagramToSvg d =
    layoutToSvg <| layoutDiagram d


box : SvgConfig a -> Box a -> Svg msg
box svgConfig b =
    Svg.g []
        [ Svg.rect
            [ x <| String.fromFloat b.lo.x
            , y <| String.fromFloat b.lo.y
            , width <| String.fromFloat b.width
            , height <| String.fromFloat b.height
            , rx <| String.fromFloat b.radius
            , ry <| String.fromFloat b.radius
            , fillOpacity "0.5"
            , stroke "grey"
            , strokeWidth "1"
            , strokeOpacity "0.5"
            , fill "#7da"
            ]
            []
        , case b.label of
            Just label ->
                svgBoxText
                    { x = b.lo.x + b.width / 2
                    , y = b.lo.y + b.height * 3 / 5
                    }
                    (svgConfig.toLabelString label)

            _ ->
                Svg.g [] []
        ]


svgBoxText : { a | x : Float, y : Float } -> String -> Svg msg
svgBoxText pos label =
    Svg.text_
        [ x <| String.fromFloat pos.x
        , y <| String.fromFloat pos.y
        , textAnchor "middle"
        , stroke "black"
        , fontSize "16"
        ]
        [ Svg.text label ]


origin : { width : number, height : number, xMin : number, yMin : number }
origin =
    { width = 1, height = 100, xMin = 0, yMin = 0 }


{-| A small viewport of 200x200
-}
smallViewport : { width : number, height : number, xMin : number, yMin : number }
smallViewport =
    { origin | width = 200, height = 200 }


{-| A wide but low viewport of 1200x150
-}
wideViewport : { width : number, height : number, xMin : number, yMin : number }
wideViewport =
    { origin | width = 1200, height = 150 }


{-| A medium sized viewport (640x480)
-}
mediumViewport : { width : number, height : number, xMin : number, yMin : number }
mediumViewport =
    { origin | width = 640, height = 480 }


{-| A larger sized viewport (1024x768)
-}
largeViewport : { width : number, height : number, xMin : number, yMin : number }
largeViewport =
    { origin | width = 1024, height = 768 }

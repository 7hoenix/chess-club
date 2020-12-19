module Skeleton exposing
    ( Details
    , Segment
    , Warning(..)
    , view
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (..)
import Svg
import Svg.Attributes



-- NODE


type alias Details msg =
    { title : String
    , header : List Segment
    , warning : Warning
    , attrs : List (Html.Attribute msg)
    , children : List (Html msg)
    }


type Warning
    = NoProblems



-- SEGMENT


type Segment
    = Text String
    | Link String String



-- VIEW


view : (a -> msg) -> Details a -> Browser.Document msg
view toMsg details =
    { title =
        details.title
    , body =
        [ viewAll toMsg details
        ]
    }


viewAll : (a -> msg) -> Details a -> Html msg
viewAll toMsg details =
    div [ class "flex min-h-screen flex-col" ]
        [ viewHeader details.header
        , viewBody toMsg details
        , viewFooter
        ]


viewBody : (a -> msg) -> Details a -> Html msg
viewBody toMsg details =
    div [ class "container mx-auto flex-1 flex flex-col mt-10 section" ]
        [ lazy viewWarning details.warning
        , Html.map toMsg <|
            div details.attrs details.children
        ]



-- VIEW HEADER


viewHeader : List Segment -> Html msg
viewHeader segments =
    div [ class "header" ]
        [ div [ class "nav" ]
            [ case segments of
                [] ->
                    text ""

                _ ->
                    h1 [] (List.intersperse slash (List.map viewSegment segments))
            ]
        ]


slash : Html msg
slash =
    span [ class "spacey-char" ] [ text "/" ]


viewSegment : Segment -> Html msg
viewSegment segment =
    case segment of
        Text string ->
            text string

        Link address string ->
            a [ href address ] [ text string ]



-- VIEW WARNING


viewWarning : Warning -> Html msg
viewWarning warning =
    div [ class "header-underbar" ] <|
        case warning of
            NoProblems ->
                []



-- VIEW FOOTER


viewFooter : Html msg
viewFooter =
    footer [ class "container mx-auto p-8 bg-white dark:bg-gray-800" ]
        [ div [ class "text-center" ]
            [ a [ class "grey-link", href "https://github.com/7hoenix/chess-club" ] [ text "Check out the code" ]
            , text " - © 2020 7hoenix Industries"
            ]
        ]

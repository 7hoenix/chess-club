module Skeleton exposing
    ( Details
    , Warning(..)
    , view
    )

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (..)
import Prelude exposing (Segment(..))



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



-- VIEW


view : String -> (a -> msg) -> Details a -> Browser.Document msg
view backendEndpoint toMsg details =
    { title =
        details.title
    , body =
        [ viewAll backendEndpoint toMsg details
        ]
    }


viewAll : String -> (a -> msg) -> Details a -> Html msg
viewAll backendEndpoint toMsg details =
    div [ class "flex flex-col w-screen min-h-screen" ]
        [ viewHeader <| [ Link backendEndpoint "7I" ] ++ details.header
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
    div [ class "header container mx-auto w-full h-10 bg-green-200 " ]
        [ div [ class "nav" ]
            [ case segments of
                [] ->
                    text ""

                _ ->
                    h1 [ class "text-black text-xl p-2" ] (List.intersperse slash (List.map viewSegment segments))
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
            , text " - © 2021 7hoenix Industries"
            ]
        ]

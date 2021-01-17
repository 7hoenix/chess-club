module Chess.Board exposing (view)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, classList)


view : Html msg
view =
    div [ class "container mx-auto h-96 w-96" ]
        [ viewBoard
        ]


viewSquare : Html msg
viewSquare =
    div [ class "bg-gray-300" ] [ text "bar" ]


viewBoard : Html msg
viewBoard =
    div [ class "grid grid-cols-8 h-full w-full border-2 border-gray-500" ]
        (List.map viewRow (List.reverse (List.range 1 8)))


viewRow : Int -> Html msg
viewRow row =
    div [ class "row h-1/8" ]
        (List.map (viewCell row) (List.range 1 8))


viewCell : Int -> Int -> Html msg
viewCell row column =
    div
        [ classList
            [ ( "square w-full h-full border border-gray-500 flex items-center justify-center", True )
            , ( shading row column, True )
            ]
        ]
        [ text <| getLetter row ++ String.fromInt column ]


shading : Int -> Int -> String
shading row column =
    if modBy 2 (row + column) == 0 then
        "bg-gray-200"

    else
        "bg-green-100"


getLetter : Int -> String
getLetter i =
    case i of
        1 ->
            "a"

        2 ->
            "b"

        3 ->
            "c"

        4 ->
            "d"

        5 ->
            "e"

        6 ->
            "f"

        7 ->
            "g"

        8 ->
            "h"

        _ ->
            "woof"

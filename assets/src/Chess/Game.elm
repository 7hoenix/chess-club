module Chess.Game exposing
    ( Callbacks
    , Color
    , Model
    , Msg
    , Piece
    , PieceType
    , blankBoard
    , fromFen
    , init
    , update
    , view
    )

import Dict exposing (Dict)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Json.Decode as D
import Json.Encode as E
import Page.Learn.Scenario exposing (Move)
import Prelude
import Svg exposing (circle, g, polygon, rect, svg)
import Svg.Attributes exposing (cx, cy, d, display, enableBackground, fill, height, id, opacity, points, r, stroke, strokeMiterlimit, style, transform, version, viewBox, width, x, y)
import Task



-- MODEL


type alias Model =
    { game : Game
    , considering : Maybe Position
    }


type Game
    = Game (Dict Position Piece) (List Move) Turn


type alias Position =
    ( Int, Int )


type Piece
    = Piece Color PieceType


type PieceType
    = Monarch
    | Advisor
    | Rook
    | Bishop
    | Knight
    | Pawn


type Turn
    = Turn Color


type Color
    = Black
    | White


blankBoard : Game
blankBoard =
    Game Dict.empty [] (Turn Black)


init : List Move -> String -> Model
init availableMoves currentState =
    Model (Result.withDefault blankBoard <| fromFen availableMoves currentState) Nothing



-- Msg


type Msg
    = StartConsidering Position
    | MakeMove Move


type alias Callbacks msg =
    { makeMove : Move -> msg
    }



-- UPDATE


update : Callbacks msg -> Msg -> Model -> ( Model, Cmd msg )
update callbacks msg model =
    case msg of
        StartConsidering position ->
            ( { model | considering = Just position }, Cmd.none )

        MakeMove move ->
            ( model, Task.perform callbacks.makeMove (Task.succeed move) )



-- VIEW BOARD


view : Model -> Html Msg
view { game, considering } =
    div [ class "container mx-auto h-96 w-96" ]
        [ viewBoard game considering
        ]


viewBoard : Game -> Maybe Position -> Html Msg
viewBoard game considering =
    div [ class "grid grid-cols-8 h-full w-full border-2 border-gray-500" ]
        (List.map (viewColumn game considering) (List.reverse (List.range 1 8)))


viewColumn : Game -> Maybe Position -> Int -> Html Msg
viewColumn game considering column =
    div [ class "column h-1/8" ]
        (List.map (viewCell game considering column) (List.range 1 8))


viewCell : Game -> Maybe Position -> Int -> Int -> Html Msg
viewCell (Game pieces moves turn) considering column row =
    div
        [ classList
            [ ( "square w-full h-full border border-gray-500 flex items-center justify-center", True )
            , ( shading column row, True )
            , ( "bg-green-500", Prelude.maybe False (\consideringPosition -> canMoveHere consideringPosition ( column, row ) moves) considering )
            , ( "considering", Prelude.maybe False (\consideringPosition -> consideringPosition == ( column, row )) considering )
            ]
        , onClick <| cellClickHandler turn moves considering ( column, row )
        ]
        (case Dict.get ( column, row ) pieces of
            Just piece ->
                [ findSvg piece [] ]

            Nothing ->
                []
        )


cellClickHandler : Turn -> List Move -> Maybe Position -> Position -> Msg
cellClickHandler turn availableMoves considering position =
    case considering of
        Nothing ->
            StartConsidering position

        Just c ->
            case friendlyMovesToPosition turn c position availableMoves of
                [] ->
                    StartConsidering position

                [ move ] ->
                    MakeMove move

                arbitraryPromotionMove :: promotionMoves ->
                    MakeMove arbitraryPromotionMove


shading : Int -> Int -> String
shading column row =
    if modBy 2 (column + row) == 0 then
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


toAlgebraic : Position -> String
toAlgebraic ( column, row ) =
    getLetter column ++ String.fromInt row



-- SQUARE PROPERTIES


friendlyMovesToPosition : Turn -> Position -> Position -> List Move -> List Move
friendlyMovesToPosition turn squareTo squareFrom moves =
    movesToPosition squareTo squareFrom moves
        |> List.filter (\move -> move.color == turnToColor turn)



-- TODO: clean this up with a custom codec.


turnToColor : Turn -> String
turnToColor (Turn color) =
    case color of
        Black ->
            "b"

        White ->
            "w"


canMoveHere : Position -> Position -> List Move -> Bool
canMoveHere squareTo squareFrom moves =
    movesToPosition squareTo squareFrom moves
        |> List.isEmpty
        |> not


movesToPosition : Position -> Position -> List Move -> List Move
movesToPosition squareTo squareFrom =
    List.filter (\move -> move.squareFrom == toAlgebraic squareFrom && move.squareTo == toAlgebraic squareTo)



-- SERIALIZATION


fromFen : List Move -> String -> Result String Game
fromFen moves fen =
    case String.split " " fen of
        [ rawBoard, rawTurn, c, d, e, f ] ->
            case ( D.decodeValue boardDecoder (E.string rawBoard), D.decodeValue turnDecoder (E.string rawTurn) ) of
                ( Ok board, Ok turn ) ->
                    Ok <| Game (Dict.fromList board) moves turn

                _ ->
                    Err <| "Something went wrong"

        _ ->
            Err <| fen ++ " doesn't look right. FEN needs to have 6 pieces of info"


turnDecoder : D.Decoder Turn
turnDecoder =
    D.andThen parseTurn D.string


parseTurn : String -> D.Decoder Turn
parseTurn t =
    case t of
        "b" ->
            D.succeed <| Turn Black

        "w" ->
            D.succeed <| Turn White

        notTurn ->
            D.fail <| notTurn ++ " is not a valid turn value"


boardDecoder : D.Decoder (List ( Position, Piece ))
boardDecoder =
    D.andThen parseFenBoard D.string


parseFenBoard : String -> D.Decoder (List ( Position, Piece ))
parseFenBoard board =
    String.split "/" board
        |> List.foldr parseFenBoardHelp (D.succeed <| Builder 1 [])
        |> D.map .pieces


parseFenBoardHelp : String -> D.Decoder Builder -> D.Decoder Builder
parseFenBoardHelp currentRow rowAccumulator =
    D.andThen (parseFenRow currentRow) rowAccumulator


parseFenRow : String -> Builder -> D.Decoder Builder
parseFenRow fenRow { acc, pieces } =
    String.toList fenRow
        |> List.reverse
        |> List.foldr (parseFenRowHelp acc) (D.succeed <| Builder 0 [])
        |> D.map (\b -> Builder (acc + 1) (b.pieces ++ pieces))


parseFenRowHelp : Int -> Char -> D.Decoder Builder -> D.Decoder Builder
parseFenRowHelp row nextColumn accumulator =
    D.andThen (parseCharacter row nextColumn) accumulator


type alias Builder =
    { acc : Int
    , pieces : List ( Position, Piece )
    }


parseCharacter : Int -> Char -> Builder -> D.Decoder Builder
parseCharacter row c { acc, pieces } =
    if Char.isDigit c then
        case String.toInt (String.fromChar c) of
            Nothing ->
                D.fail "not a digit"

            Just cc ->
                D.succeed (Builder (acc + cc) pieces)

    else
        case parsePieceType <| Char.toLower c of
            Err err ->
                D.fail err

            Ok pieceType ->
                D.succeed (Builder (acc + 1) (pieces ++ [ ( ( acc + 1, row ), Piece (parseColor c) pieceType ) ]))


parseColor : Char -> Color
parseColor c =
    if Char.isLower c then
        Black

    else
        White


parsePieceType : Char -> Result String PieceType
parsePieceType c =
    case c of
        'k' ->
            Ok Monarch

        'q' ->
            Ok Advisor

        'r' ->
            Ok Rook

        'b' ->
            Ok Bishop

        'n' ->
            Ok Knight

        'p' ->
            Ok Pawn

        cc ->
            Err <| String.fromChar cc ++ " is not a valid pieceType"



-- SVG


{-| -}
findSvg : Piece -> List (Html.Attribute msg) -> Html msg
findSvg (Piece color pieceType) =
    case ( color, pieceType ) of
        ( White, Pawn ) ->
            whitePawn

        ( Black, Pawn ) ->
            blackPawn

        ( White, Bishop ) ->
            whiteBishop

        ( Black, Bishop ) ->
            blackBishop

        ( White, Knight ) ->
            whiteKnight

        ( Black, Knight ) ->
            blackKnight

        ( White, Rook ) ->
            whiteRook

        ( Black, Rook ) ->
            blackRook

        ( White, Advisor ) ->
            whiteAdvisor

        ( Black, Advisor ) ->
            blackAdvisor

        ( White, Monarch ) ->
            whiteMonarch

        ( Black, Monarch ) ->
            blackMonarch


blackPawn : List (Html.Attribute msg) -> Html msg
blackPawn extraArguments =
    svg [ version "1.1", width "45", height "45" ] [ Svg.path [ d "m 22.5,9 c -2.21,0 -4,1.79 -4,4 0,0.89 0.29,1.71 0.78,2.38 C 17.33,16.5 16,18.59 16,21 c 0,2.03 0.94,3.84 2.41,5.03 C 15.41,27.09 11,31.58 11,39.5 H 34 C 34,31.58 29.59,27.09 26.59,26.03 28.06,24.84 29,23.03 29,21 29,18.59 27.67,16.5 25.72,15.38 26.21,14.71 26.5,13.89 26.5,13 c 0,-2.21 -1.79,-4 -4,-4 z", style "opacity:1; fill:#000000; fill-opacity:1; fill-rule:nonzero; stroke:#000000; stroke-width:1.5; stroke-linecap:round; stroke-linejoin:miter; stroke-miterlimit:4; stroke-dasharray:none; stroke-opacity:1;" ] [] ]


whitePawn : List (Html.Attribute msg) -> Html msg
whitePawn extraAttributes =
    svg [ version "1.1", width "45", height "45" ] [ Svg.path [ d "m 22.5,9 c -2.21,0 -4,1.79 -4,4 0,0.89 0.29,1.71 0.78,2.38 C 17.33,16.5 16,18.59 16,21 c 0,2.03 0.94,3.84 2.41,5.03 C 15.41,27.09 11,31.58 11,39.5 H 34 C 34,31.58 29.59,27.09 26.59,26.03 28.06,24.84 29,23.03 29,21 29,18.59 27.67,16.5 25.72,15.38 26.21,14.71 26.5,13.89 26.5,13 c 0,-2.21 -1.79,-4 -4,-4 z", style "opacity:1; fill:#ffffff; fill-opacity:1; fill-rule:nonzero; stroke:#000000; stroke-width:1.5; stroke-linecap:round; stroke-linejoin:miter; stroke-miterlimit:4; stroke-dasharray:none; stroke-opacity:1;" ] [] ]


blackBishop : List (Html.Attribute msg) -> Html msg
blackBishop extraAttributes =
    svg [ version "1.1", width "45", height "45" ] [ g [ style "opacity:1; fill:none; fill-rule:evenodd; fill-opacity:1; stroke:#000000; stroke-width:1.5; stroke-linecap:round; stroke-linejoin:round; stroke-miterlimit:4; stroke-dasharray:none; stroke-opacity:1;" ] [ g [ style "fill:#000000; stroke:#000000; stroke-linecap:butt;" ] [ Svg.path [ d "M 9,36 C 12.39,35.03 19.11,36.43 22.5,34 C 25.89,36.43 32.61,35.03 36,36 C 36,36 37.65,36.54 39,38 C 38.32,38.97 37.35,38.99 36,38.5 C 32.61,37.53 25.89,38.96 22.5,37.5 C 19.11,38.96 12.39,37.53 9,38.5 C 7.65,38.99 6.68,38.97 6,38 C 7.35,36.54 9,36 9,36 z" ] [], Svg.path [ d "M 15,32 C 17.5,34.5 27.5,34.5 30,32 C 30.5,30.5 30,30 30,30 C 30,27.5 27.5,26 27.5,26 C 33,24.5 33.5,14.5 22.5,10.5 C 11.5,14.5 12,24.5 17.5,26 C 17.5,26 15,27.5 15,30 C 15,30 14.5,30.5 15,32 z" ] [], Svg.path [ d "M 25 8 A 2.5 2.5 0 1 1 20,8 A 2.5 2.5 0 1 1 25 8 z" ] [] ], Svg.path [ d "M 17.5,26 L 27.5,26 M 15,30 L 30,30 M 22.5,15.5 L 22.5,20.5 M 20,18 L 25,18", style "fill:none; stroke:#ffffff; stroke-linejoin:miter;" ] [] ] ]


whiteBishop : List (Html.Attribute msg) -> Html msg
whiteBishop extraAttributes =
    svg [ version "1.1", width "45", height "45" ] [ g [ style "opacity:1; fill:none; fill-rule:evenodd; fill-opacity:1; stroke:#000000; stroke-width:1.5; stroke-linecap:round; stroke-linejoin:round; stroke-miterlimit:4; stroke-dasharray:none; stroke-opacity:1;" ] [ g [ style "fill:#ffffff; stroke:#000000; stroke-linecap:butt;" ] [ Svg.path [ d "M 9,36 C 12.39,35.03 19.11,36.43 22.5,34 C 25.89,36.43 32.61,35.03 36,36 C 36,36 37.65,36.54 39,38 C 38.32,38.97 37.35,38.99 36,38.5 C 32.61,37.53 25.89,38.96 22.5,37.5 C 19.11,38.96 12.39,37.53 9,38.5 C 7.65,38.99 6.68,38.97 6,38 C 7.35,36.54 9,36 9,36 z" ] [], Svg.path [ d "M 15,32 C 17.5,34.5 27.5,34.5 30,32 C 30.5,30.5 30,30 30,30 C 30,27.5 27.5,26 27.5,26 C 33,24.5 33.5,14.5 22.5,10.5 C 11.5,14.5 12,24.5 17.5,26 C 17.5,26 15,27.5 15,30 C 15,30 14.5,30.5 15,32 z" ] [], Svg.path [ d "M 25 8 A 2.5 2.5 0 1 1 20,8 A 2.5 2.5 0 1 1 25 8 z" ] [] ], Svg.path [ d "M 17.5,26 L 27.5,26 M 15,30 L 30,30 M 22.5,15.5 L 22.5,20.5 M 20,18 L 25,18", style "fill:none; stroke:#000000; stroke-linejoin:miter;" ] [] ] ]


blackKnight : List (Html.Attribute msg) -> Html msg
blackKnight extraAttributes =
    svg [ version "1.1", width "45", height "45" ] [ g [ style "opacity:1; fill:none; fill-opacity:1; fill-rule:evenodd; stroke:#000000; stroke-width:1.5; stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4; stroke-dasharray:none; stroke-opacity:1;" ] [ Svg.path [ d "M 22,10 C 32.5,11 38.5,18 38,39 L 15,39 C 15,30 25,32.5 23,18", style "fill:#000000; stroke:#000000;" ] [], Svg.path [ d "M 24,18 C 24.38,20.91 18.45,25.37 16,27 C 13,29 13.18,31.34 11,31 C 9.958,30.06 12.41,27.96 11,28 C 10,28 11.19,29.23 10,30 C 9,30 5.997,31 6,26 C 6,24 12,14 12,14 C 12,14 13.89,12.1 14,10.5 C 13.27,9.506 13.5,8.5 13.5,7.5 C 14.5,6.5 16.5,10 16.5,10 L 18.5,10 C 18.5,10 19.28,8.008 21,7 C 22,7 22,10 22,10", style "fill:#000000; stroke:#000000;" ] [], Svg.path [ d "M 9.5 25.5 A 0.5 0.5 0 1 1 8.5,25.5 A 0.5 0.5 0 1 1 9.5 25.5 z", style "fill:#ffffff; stroke:#ffffff;" ] [], Svg.path [ d "M 15 15.5 A 0.5 1.5 0 1 1 14,15.5 A 0.5 1.5 0 1 1 15 15.5 z", transform "matrix(0.866,0.5,-0.5,0.866,9.693,-5.173)", style "fill:#ffffff; stroke:#ffffff;" ] [], Svg.path [ d "M 24.55,10.4 L 24.1,11.85 L 24.6,12 C 27.75,13 30.25,14.49 32.5,18.75 C 34.75,23.01 35.75,29.06 35.25,39 L 35.2,39.5 L 37.45,39.5 L 37.5,39 C 38,28.94 36.62,22.15 34.25,17.66 C 31.88,13.17 28.46,11.02 25.06,10.5 L 24.55,10.4 z ", style "fill:#ffffff; stroke:none;" ] [] ] ]


whiteKnight : List (Html.Attribute msg) -> Html msg
whiteKnight extraAttributes =
    svg [ version "1.1", width "45", height "45" ] [ g [ style "opacity:1; fill:none; fill-opacity:1; fill-rule:evenodd; stroke:#000000; stroke-width:1.5; stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4; stroke-dasharray:none; stroke-opacity:1;" ] [ Svg.path [ d "M 22,10 C 32.5,11 38.5,18 38,39 L 15,39 C 15,30 25,32.5 23,18", style "fill:#ffffff; stroke:#000000;" ] [], Svg.path [ d "M 24,18 C 24.38,20.91 18.45,25.37 16,27 C 13,29 13.18,31.34 11,31 C 9.958,30.06 12.41,27.96 11,28 C 10,28 11.19,29.23 10,30 C 9,30 5.997,31 6,26 C 6,24 12,14 12,14 C 12,14 13.89,12.1 14,10.5 C 13.27,9.506 13.5,8.5 13.5,7.5 C 14.5,6.5 16.5,10 16.5,10 L 18.5,10 C 18.5,10 19.28,8.008 21,7 C 22,7 22,10 22,10", style "fill:#ffffff; stroke:#000000;" ] [], Svg.path [ d "M 9.5 25.5 A 0.5 0.5 0 1 1 8.5,25.5 A 0.5 0.5 0 1 1 9.5 25.5 z", style "fill:#000000; stroke:#000000;" ] [], Svg.path [ d "M 15 15.5 A 0.5 1.5 0 1 1 14,15.5 A 0.5 1.5 0 1 1 15 15.5 z", transform "matrix(0.866,0.5,-0.5,0.866,9.693,-5.173)", style "fill:#000000; stroke:#000000;" ] [] ] ]


blackRook : List (Html.Attribute msg) -> Html msg
blackRook extraAttributes =
    svg [ version "1.1", width "45", height "45" ] [ g [ style "opacity:1; fill:000000; fill-opacity:1; fill-rule:evenodd; stroke:#000000; stroke-width:1.5; stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4; stroke-dasharray:none; stroke-opacity:1;" ] [ Svg.path [ d "M 9,39 L 36,39 L 36,36 L 9,36 L 9,39 z ", style "stroke-linecap:butt;" ] [], Svg.path [ d "M 12.5,32 L 14,29.5 L 31,29.5 L 32.5,32 L 12.5,32 z ", style "stroke-linecap:butt;" ] [], Svg.path [ d "M 12,36 L 12,32 L 33,32 L 33,36 L 12,36 z ", style "stroke-linecap:butt;" ] [], Svg.path [ d "M 14,29.5 L 14,16.5 L 31,16.5 L 31,29.5 L 14,29.5 z ", style "stroke-linecap:butt;stroke-linejoin:miter;" ] [], Svg.path [ d "M 14,16.5 L 11,14 L 34,14 L 31,16.5 L 14,16.5 z ", style "stroke-linecap:butt;" ] [], Svg.path [ d "M 11,14 L 11,9 L 15,9 L 15,11 L 20,11 L 20,9 L 25,9 L 25,11 L 30,11 L 30,9 L 34,9 L 34,14 L 11,14 z ", style "stroke-linecap:butt;" ] [], Svg.path [ d "M 12,35.5 L 33,35.5 L 33,35.5", style "fill:none; stroke:#ffffff; stroke-width:1; stroke-linejoin:miter;" ] [], Svg.path [ d "M 13,31.5 L 32,31.5", style "fill:none; stroke:#ffffff; stroke-width:1; stroke-linejoin:miter;" ] [], Svg.path [ d "M 14,29.5 L 31,29.5", style "fill:none; stroke:#ffffff; stroke-width:1; stroke-linejoin:miter;" ] [], Svg.path [ d "M 14,16.5 L 31,16.5", style "fill:none; stroke:#ffffff; stroke-width:1; stroke-linejoin:miter;" ] [], Svg.path [ d "M 11,14 L 34,14", style "fill:none; stroke:#ffffff; stroke-width:1; stroke-linejoin:miter;" ] [] ] ]


whiteRook : List (Html.Attribute msg) -> Html msg
whiteRook extraAttributes =
    svg [ version "1.1", width "45", height "45" ] [ g [ style "opacity:1; fill:#ffffff; fill-opacity:1; fill-rule:evenodd; stroke:#000000; stroke-width:1.5; stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4; stroke-dasharray:none; stroke-opacity:1;" ] [ Svg.path [ d "M 9,39 L 36,39 L 36,36 L 9,36 L 9,39 z ", style "stroke-linecap:butt;" ] [], Svg.path [ d "M 12,36 L 12,32 L 33,32 L 33,36 L 12,36 z ", style "stroke-linecap:butt;" ] [], Svg.path [ d "M 11,14 L 11,9 L 15,9 L 15,11 L 20,11 L 20,9 L 25,9 L 25,11 L 30,11 L 30,9 L 34,9 L 34,14", style "stroke-linecap:butt;" ] [], Svg.path [ d "M 34,14 L 31,17 L 14,17 L 11,14" ] [], Svg.path [ d "M 31,17 L 31,29.5 L 14,29.5 L 14,17", style "stroke-linecap:butt; stroke-linejoin:miter;" ] [], Svg.path [ d "M 31,29.5 L 32.5,32 L 12.5,32 L 14,29.5" ] [], Svg.path [ d "M 11,14 L 34,14", style "fill:none; stroke:#000000; stroke-linejoin:miter;" ] [] ] ]


blackAdvisor : List (Html.Attribute msg) -> Html msg
blackAdvisor extraAttributes =
    svg [ version "1.1", width "45", height "45" ] [ g [ style "opacity:1; fill:000000; fill-opacity:1; fill-rule:evenodd; stroke:#000000; stroke-width:1.5; stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4; stroke-dasharray:none; stroke-opacity:1;" ] [ g [ style "fill:#000000; stroke:none;" ] [ circle [ cx "6", cy "12", r "2.75" ] [], circle [ cx "14", cy "9", r "2.75" ] [], circle [ cx "22.5", cy "8", r "2.75" ] [], circle [ cx "31", cy "9", r "2.75" ] [], circle [ cx "39", cy "12", r "2.75" ] [] ], Svg.path [ d "M 9,26 C 17.5,24.5 30,24.5 36,26 L 38.5,13.5 L 31,25 L 30.7,10.9 L 25.5,24.5 L 22.5,10 L 19.5,24.5 L 14.3,10.9 L 14,25 L 6.5,13.5 L 9,26 z", style "stroke-linecap:butt; stroke:#000000;" ] [], Svg.path [ d "M 9,26 C 9,28 10.5,28 11.5,30 C 12.5,31.5 12.5,31 12,33.5 C 10.5,34.5 11,36 11,36 C 9.5,37.5 11,38.5 11,38.5 C 17.5,39.5 27.5,39.5 34,38.5 C 34,38.5 35.5,37.5 34,36 C 34,36 34.5,34.5 33,33.5 C 32.5,31 32.5,31.5 33.5,30 C 34.5,28 36,28 36,26 C 27.5,24.5 17.5,24.5 9,26 z", style "stroke-linecap:butt;" ] [], Svg.path [ d "M 11,38.5 A 35,35 1 0 0 34,38.5", style "fill:none; stroke:#000000; stroke-linecap:butt;" ] [], Svg.path [ d "M 11,29 A 35,35 1 0 1 34,29", style "fill:none; stroke:#ffffff;" ] [], Svg.path [ d "M 12.5,31.5 L 32.5,31.5", style "fill:none; stroke:#ffffff;" ] [], Svg.path [ d "M 11.5,34.5 A 35,35 1 0 0 33.5,34.5", style "fill:none; stroke:#ffffff;" ] [], Svg.path [ d "M 10.5,37.5 A 35,35 1 0 0 34.5,37.5", style "fill:none; stroke:#ffffff;" ] [] ] ]


whiteAdvisor : List (Html.Attribute msg) -> Html msg
whiteAdvisor extraAttributes =
    svg [ version "1.1", width "45", height "45" ] [ g [ style "opacity:1; fill:#ffffff; fill-opacity:1; fill-rule:evenodd; stroke:#000000; stroke-width:1.5; stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4; stroke-dasharray:none; stroke-opacity:1;" ] [ Svg.path [ d "M 9 13 A 2 2 0 1 1 5,13 A 2 2 0 1 1 9 13 z", transform "translate(-1,-1)" ] [], Svg.path [ d "M 9 13 A 2 2 0 1 1 5,13 A 2 2 0 1 1 9 13 z", transform "translate(15.5,-5.5)" ] [], Svg.path [ d "M 9 13 A 2 2 0 1 1 5,13 A 2 2 0 1 1 9 13 z", transform "translate(32,-1)" ] [], Svg.path [ d "M 9 13 A 2 2 0 1 1 5,13 A 2 2 0 1 1 9 13 z", transform "translate(7,-4)" ] [], Svg.path [ d "M 9 13 A 2 2 0 1 1 5,13 A 2 2 0 1 1 9 13 z", transform "translate(24,-4)" ] [], Svg.path [ d "M 9,26 C 17.5,24.5 27.5,24.5 36,26 L 38,14 L 31,25 L 31,11 L 25.5,24.5 L 22.5,9.5 L 19.5,24.5 L 14,11 L 14,25 L 7,14 L 9,26 z ", style "stroke-linecap:butt;" ] [], Svg.path [ d "M 9,26 C 9,28 10.5,28 11.5,30 C 12.5,31.5 12.5,31 12,33.5 C 10.5,34.5 11,36 11,36 C 9.5,37.5 11,38.5 11,38.5 C 17.5,39.5 27.5,39.5 34,38.5 C 34,38.5 35.5,37.5 34,36 C 34,36 34.5,34.5 33,33.5 C 32.5,31 32.5,31.5 33.5,30 C 34.5,28 36,28 36,26 C 27.5,24.5 17.5,24.5 9,26 z", style "stroke-linecap:butt;" ] [], Svg.path [ d "M 11.5,30 C 15,29 30,29 33.5,30", style "fill:none;" ] [], Svg.path [ d "M 12,33.5 C 18,32.5 27,32.5 33,33.5", style "fill:none;" ] [] ] ]


blackMonarch : List (Html.Attribute msg) -> Html msg
blackMonarch extraAttributes =
    svg [ version "1.1", width "45", height "45" ] [ g [ style "fill:none; fill-opacity:1; fill-rule:evenodd; stroke:#000000; stroke-width:1.5; stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4; stroke-dasharray:none; stroke-opacity:1;" ] [ Svg.path [ d "M 22.5,11.63 L 22.5,6", style "fill:none; stroke:#000000; stroke-linejoin:miter;", id "path6570" ] [], Svg.path [ d "M 22.5,25 C 22.5,25 27,17.5 25.5,14.5 C 25.5,14.5 24.5,12 22.5,12 C 20.5,12 19.5,14.5 19.5,14.5 C 18,17.5 22.5,25 22.5,25", style "fill:#000000;fill-opacity:1; stroke-linecap:butt; stroke-linejoin:miter;" ] [], Svg.path [ d "M 12.5,37 C 18,40.5 27,40.5 32.5,37 L 32.5,30 C 32.5,30 41.5,25.5 38.5,19.5 C 34.5,13 25,16 22.5,23.5 L 22.5,27 L 22.5,23.5 C 20,16 10.5,13 6.5,19.5 C 3.5,25.5 12.5,30 12.5,30 L 12.5,37", style "fill:#000000; stroke:#000000;" ] [], Svg.path [ d "M 20,8 L 25,8", style "fill:none; stroke:#000000; stroke-linejoin:miter;" ] [], Svg.path [ d "M 32,29.5 C 32,29.5 40.5,25.5 38.03,19.85 C 34.15,14 25,18 22.5,24.5 L 22.5,26.6 L 22.5,24.5 C 20,18 10.85,14 6.97,19.85 C 4.5,25.5 13,29.5 13,29.5", style "fill:none; stroke:#ffffff;" ] [], Svg.path [ d "M 12.5,30 C 18,27 27,27 32.5,30 M 12.5,33.5 C 18,30.5 27,30.5 32.5,33.5 M 12.5,37 C 18,34 27,34 32.5,37", style "fill:none; stroke:#ffffff;" ] [] ] ]


whiteMonarch : List (Html.Attribute msg) -> Html msg
whiteMonarch extraAttributes =
    svg [ version "1.1", width "45", height "45" ] [ g [ style "fill:none; fill-opacity:1; fill-rule:evenodd; stroke:#000000; stroke-width:1.5; stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4; stroke-dasharray:none; stroke-opacity:1;" ] [ Svg.path [ d "M 22.5,11.63 L 22.5,6", style "fill:none; stroke:#000000; stroke-linejoin:miter;" ] [], Svg.path [ d "M 20,8 L 25,8", style "fill:none; stroke:#000000; stroke-linejoin:miter;" ] [], Svg.path [ d "M 22.5,25 C 22.5,25 27,17.5 25.5,14.5 C 25.5,14.5 24.5,12 22.5,12 C 20.5,12 19.5,14.5 19.5,14.5 C 18,17.5 22.5,25 22.5,25", style "fill:#ffffff; stroke:#000000; stroke-linecap:butt; stroke-linejoin:miter;" ] [], Svg.path [ d "M 12.5,37 C 18,40.5 27,40.5 32.5,37 L 32.5,30 C 32.5,30 41.5,25.5 38.5,19.5 C 34.5,13 25,16 22.5,23.5 L 22.5,27 L 22.5,23.5 C 20,16 10.5,13 6.5,19.5 C 3.5,25.5 12.5,30 12.5,30 L 12.5,37", style "fill:#ffffff; stroke:#000000;" ] [], Svg.path [ d "M 12.5,30 C 18,27 27,27 32.5,30", style "fill:none; stroke:#000000;" ] [], Svg.path [ d "M 12.5,33.5 C 18,30.5 27,30.5 32.5,33.5", style "fill:none; stroke:#000000;" ] [], Svg.path [ d "M 12.5,37 C 18,34 27,34 32.5,37", style "fill:none; stroke:#000000;" ] [] ] ]

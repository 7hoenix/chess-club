module Chess.Game exposing (blankBoard, fromFen, view)

import Dict exposing (Dict)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, classList)
import Json.Decode as D
import Json.Encode as E



-- MODEL


type alias Model =
    { game : Game
    }


type Game
    = Game (Dict Position Piece) Turn


type alias Position =
    ( Int, Int )


type Piece
    = Piece Color PieceType


type Turn
    = Turn Color


type PieceType
    = Monarch
    | Advisor
    | Rook
    | Bishop
    | Knight
    | Pawn


type Color
    = Black
    | White


blankBoard : Game
blankBoard =
    Game Dict.empty (Turn Black)



-- fromFen


fromFen : String -> Result String Game
fromFen fen =
    case String.split " " fen of
        [ rawBoard, rawTurn, c, d, e, f ] ->
            case ( D.decodeValue boardDecoder (E.string rawBoard), D.decodeValue turnDecoder (E.string rawTurn) ) of
                ( Ok board, Ok turn ) ->
                    Ok <| Game (Dict.fromList board) turn

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



-- VIEW BOARD


view : Game -> Html msg
view game =
    div [ class "container mx-auto h-96 w-96" ]
        [ viewBoard game
        ]


viewSquare : Html msg
viewSquare =
    div [ class "bg-gray-300" ] [ text "bar" ]


viewBoard : Game -> Html msg
viewBoard game =
    div [ class "grid grid-cols-8 h-full w-full border-2 border-gray-500" ]
        (List.map (viewRow game) (List.reverse (List.range 1 8)))


viewRow : Game -> Int -> Html msg
viewRow game row =
    div [ class "row h-1/8" ]
        (List.map (viewCell game row) (List.range 1 8))


viewCell : Game -> Int -> Int -> Html msg
viewCell (Game pieces turn) row column =
    let
        foo =
            Debug.log "pieces" pieces
    in
    div
        [ classList
            [ ( "square w-full h-full border border-gray-500 flex items-center justify-center", True )
            , ( shading row column, True )
            ]
        ]
        (case Dict.get ( row, column ) pieces of
            Just piece ->
                [ text "O" ]

            Nothing ->
                [ text "" ]
        )


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

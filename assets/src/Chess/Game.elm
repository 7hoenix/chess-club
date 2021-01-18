module Chess.Game exposing (Callbacks, Model, Msg, blankBoard, fromFen, init, update, view)

import Dict exposing (Dict)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Json.Decode as D
import Json.Encode as E
import Page.Learn.Scenario exposing (Move)
import Prelude
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
                [ text "O" ]

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

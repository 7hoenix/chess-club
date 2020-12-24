module Page.LearnTest exposing (all, start)

import Api.Scalar exposing (Id(..))
import Chess.Game as Chess
import Expect
import Json.Decode
import Json.Encode
import Page.Learn as Learn
import Page.Learn.Scenario as Scenario
import ProgramTest exposing (ProgramTest, clickButton, ensureViewHas, expectViewHas, fillIn, update)
import SimulatedEffect.Cmd
import Skeleton
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector as Selector exposing (text)


blackMonarch =
    Chess.Piece Chess.Monarch Chess.Black


whiteMonarch =
    Chess.Piece Chess.Monarch Chess.White


whitePawn =
    Chess.Piece Chess.Pawn Chess.White


initialStartingState =
    "some-fen-string"


loadedData =
    { scenarios = Just [ Scenario.Scenario initialStartingState (Id "1") ]
    , backendEndpoint = "http://foo.bar"
    }


simulateEffects : Learn.Effect -> ProgramTest.SimulatedEffect Learn.Msg
simulateEffects effect =
    case effect of
        Learn.NoEffect ->
            SimulatedEffect.Cmd.none

        Learn.GetScenarios _ ->
            SimulatedEffect.Cmd.none


start : Chess.Game -> ProgramTest Learn.Model Learn.Msg Learn.Effect
start g =
    ProgramTest.createDocument
        { init = \_ -> Learn.init loadedData
        , view = \model -> Skeleton.view (\msg -> msg) (Learn.view model)
        , update = Learn.update
        }
        |> ProgramTest.withSimulatedEffects simulateEffects
        |> ProgramTest.start ()


all : Test
all =
    describe "Learn page"
        [ test "shows trivial" <|
            \() ->
                start (Chess.init Chess.starterConfig)
                    |> expectViewHas [ text initialStartingState ]
        , test "displays all valid moves for your piece" <|
            \() ->
                let
                    -- White pawn and monarch may both move to the same square g5.
                    game =
                        Chess.init Chess.starterConfig
                            |> Chess.put blackMonarch Chess.g8
                            |> Chess.put whiteMonarch Chess.g6
                            |> Chess.put whitePawn Chess.g4

                    gameInFen =
                        "6k1/8/6K1/8/6P1/8/8/8 b - - 0 77"
                in
                start game
                    |> ProgramTest.ensureOutgoingPortValues
                        "validMoves"
                        Json.Decode.string
                        (Expect.equal [ gameInFen ])
                    |> ProgramTest.simulateIncomingPort
                        "validMovesResults"
                        (Json.Encode.list Json.Encode.string
                            --(Json.Encode.list Chess.Move.encode
                            [ "foo change me" ]
                        )
                    |> ensureViewHas [ Selector.class <| positionToCssClass Chess.h8, Selector.class <| teamAsCss Chess.Black 1 ]
                    |> ensureViewHas [ Selector.class <| positionToCssClass Chess.f8, Selector.class <| teamAsCss Chess.Black 1 ]
                    |> ensureViewHas [ Selector.class <| positionToCssClass Chess.h6, Selector.class <| teamAsCss Chess.White 1 ]
                    |> ensureViewHas [ Selector.class <| positionToCssClass Chess.f6, Selector.class <| teamAsCss Chess.White 1 ]
                    |> ensureViewHas [ Selector.class <| positionToCssClass Chess.h5, Selector.class <| teamAsCss Chess.White 1 ]
                    |> ensureViewHas [ Selector.class <| positionToCssClass Chess.g5, Selector.class <| teamAsCss Chess.White 2 ]
                    |> expectViewHas [ Selector.class <| positionToCssClass Chess.f5, Selector.class <| teamAsCss Chess.White 1 ]
        ]


positionToCssClass : Chess.Position -> String
positionToCssClass (Chess.Position file rank) =
    let
        fileAsString =
            case file of
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
                    Debug.todo "Invalid file found. Should be impossible."
    in
    fileAsString ++ String.fromInt rank


teamAsCss team veracity =
    case team of
        Chess.Black ->
            "black-" ++ String.fromInt veracity

        Chess.White ->
            "white-" ++ String.fromInt veracity



--expectSquaresAreMoveableFor team square veracity c =
--    let
--        teamAsCss =
--            case team of
--                Chess.Black ->
--                    "black-" ++ String.fromInt veracity
--
--                Chess.White ->
--                    "white-" ++ String.fromInt veracity
--    in
--    c
--        |> Query.find [ Selector.class teamAsCss ]
--        |> expectViewHas [ Selector.class <| positionToCssClass square ]
--(List.map
--    \squareLocation ->
--    (Query.find [ Selector.class teamAsCss, Selector.class <| positionToCssClass squareLocation ]) squares)

module Chess.LogicTest exposing (all)

import Chess.Logic as Chess
import Expect exposing (..)
import Test exposing (..)


team =
    Chess.Black


opponentTeam =
    Chess.White


monarch =
    Chess.Piece Chess.Monarch team


hand =
    Chess.Piece Chess.Hand team


bishop =
    Chess.Piece Chess.Bishop team


rook =
    Chess.Piece Chess.Rook team


opponentRook =
    Chess.Piece Chess.Rook opponentTeam


diagonalMovesFromD4 =
    [ -- North East
      Chess.c3
    , Chess.b2
    , Chess.a1

    -- South East
    , Chess.c5
    , Chess.b6
    , Chess.a7

    -- North West
    , Chess.e3
    , Chess.f2
    , Chess.g1

    -- South West
    , Chess.e5
    , Chess.f6
    , Chess.g7
    , Chess.h8
    ]


horizontalMovesFromD4 =
    [ -- North
      Chess.d3
    , Chess.d2
    , Chess.d1

    -- South
    , Chess.d5
    , Chess.d6
    , Chess.d7
    , Chess.d8

    -- West
    , Chess.e4
    , Chess.f4
    , Chess.g4
    , Chess.h4

    -- East
    , Chess.c4
    , Chess.b4
    , Chess.a4
    ]


all : Test
all =
    describe "Chess"
        [ describe "canMoveTo" <|
            [ describe "single piece" <|
                [ test "monarch movement" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Chess.b2 monarch

                            game =
                                Chess.init [ current ] team

                            validSquares =
                                [ Chess.a1
                                , Chess.a2
                                , Chess.a3
                                , Chess.b1
                                , Chess.b3
                                , Chess.c1
                                , Chess.c2
                                , Chess.c3
                                ]
                        in
                        Expect.true
                            "Knows monarch moves"
                            (List.all
                                (\pos -> Chess.canMoveTo pos game == [ Chess.b2 ])
                                validSquares
                            )
                , test "monarch invalid moves" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Chess.b2 monarch

                            game =
                                Chess.init [ current ] team

                            validSquares =
                                [ Chess.a1
                                , Chess.a2
                                , Chess.a3
                                , Chess.b1
                                , Chess.b3
                                , Chess.c1
                                , Chess.c2
                                , Chess.c3
                                ]

                            otherSquares =
                                List.filter (\s -> not (List.member s validSquares)) Chess.all
                        in
                        Expect.true
                            "Not valid monarch movement"
                            (List.all
                                (\pos -> Chess.canMoveTo pos game == [])
                                otherSquares
                            )
                , test "bishop movement" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Chess.d4 bishop

                            game =
                                Chess.init [ current ] team
                        in
                        Expect.true
                            "Knows bishop moves"
                            (List.all
                                (\pos -> Chess.canMoveTo pos game == [ Chess.d4 ])
                                diagonalMovesFromD4
                            )
                , test "bishop invalid moves" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Chess.d4 bishop

                            game =
                                Chess.init [ current ] team

                            otherSquares =
                                List.filter (\s -> not (List.member s diagonalMovesFromD4)) Chess.all
                        in
                        Expect.true
                            "Not valid bishop movement"
                            (List.all
                                (\pos -> Chess.canMoveTo pos game == [])
                                otherSquares
                            )
                , test "rook movement" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Chess.d4 rook

                            game =
                                Chess.init [ current ] team
                        in
                        Expect.true
                            "Knows rook moves"
                            (List.all
                                (\pos -> Chess.canMoveTo pos game == [ Chess.d4 ])
                                horizontalMovesFromD4
                            )
                , test "Rook invalid moves" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Chess.d4 rook

                            game =
                                Chess.init [ current ] team

                            otherSquares =
                                List.filter (\s -> not (List.member s horizontalMovesFromD4)) Chess.all
                        in
                        Expect.true
                            "Not valid rook movement"
                            (List.all
                                (\pos -> Chess.canMoveTo pos game == [])
                                otherSquares
                            )
                , test "hand movement" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Chess.d4 hand

                            game =
                                Chess.init [ current ] team
                        in
                        Expect.true
                            "Knows hand moves"
                            (List.all
                                (\pos -> Chess.canMoveTo pos game == [ Chess.d4 ])
                                (horizontalMovesFromD4 ++ diagonalMovesFromD4)
                            )
                , test "Hand invalid moves" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Chess.d4 hand

                            game =
                                Chess.init [ current ] team

                            otherSquares =
                                List.filter
                                    (\s ->
                                        not
                                            (List.member s
                                                (horizontalMovesFromD4 ++ diagonalMovesFromD4)
                                            )
                                    )
                                    Chess.all
                        in
                        Expect.equal []
                            (List.filter
                                (\pos -> Chess.canMoveTo pos game /= [])
                                otherSquares
                            )
                ]
            , describe "more pieces" <|
                [ test "movement not allowed if blocked by pieces" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Chess.a1 hand

                            friendly position =
                                Chess.Occupied position rook

                            opponent position =
                                Chess.Occupied position opponentRook

                            game =
                                Chess.init [ friendly Chess.a2, current, friendly Chess.b1, opponent Chess.b2 ] team
                        in
                        Expect.equal [ Chess.b2 ]
                            (List.filter
                                (\pos -> List.member Chess.a1 (Chess.canMoveTo pos game))
                                Chess.all
                            )
                ]
            ]
        ]

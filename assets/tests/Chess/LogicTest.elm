module Chess.LogicTest exposing (all)

import Chess.Logic as Chess exposing (Piece, PieceType(..), Square)
import Chess.Position as Position exposing (Position(..))
import Expect exposing (..)
import Fuzz exposing (Fuzzer)
import Test exposing (..)


team =
    Chess.Black


opponentTeam =
    Chess.White


monarch =
    Chess.Piece Chess.Monarch team


advisor =
    Chess.Piece Chess.Advisor team


opponentAdvisor =
    Chess.Piece Chess.Advisor opponentTeam


rook =
    Chess.Piece Chess.Rook team


opponentRook =
    Chess.Piece Chess.Rook opponentTeam


bishop =
    Chess.Piece Chess.Bishop team


opponentBishop =
    Chess.Piece Chess.Bishop opponentTeam


diagonalMovesFromD4 =
    [ -- North East
      Position.c3
    , Position.b2
    , Position.a1

    -- South East
    , Position.c5
    , Position.b6
    , Position.a7

    -- North West
    , Position.e3
    , Position.f2
    , Position.g1

    -- South West
    , Position.e5
    , Position.f6
    , Position.g7
    , Position.h8
    ]


horizontalMovesFromD4 =
    [ -- North
      Position.d3
    , Position.d2
    , Position.d1

    -- South
    , Position.d5
    , Position.d6
    , Position.d7
    , Position.d8

    -- West
    , Position.e4
    , Position.f4
    , Position.g4
    , Position.h4

    -- East
    , Position.c4
    , Position.b4
    , Position.a4
    ]


pieceTypeFuzzer : Fuzzer PieceType
pieceTypeFuzzer =
    Fuzz.frequency
        [ ( 1, Fuzz.constant Advisor )
        , ( 1, Fuzz.constant Rook )
        , ( 1, Fuzz.constant Bishop )
        ]


position : Square -> ( Int, Int )
position (Chess.Occupied (Position px py) _) =
    ( px, py )


all : Test
all =
    describe "Chess"
        [ describe "forcingMoves" <|
            [ describe "recognizes checkmate as bottom" <|
                [ test "will find checkmate" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.h1 monarch

                            attackers =
                                [ Chess.Occupied Position.g8 opponentRook
                                , Chess.Occupied Position.g7 opponentRook
                                ]

                            game =
                                Chess.init (attackers ++ [ current ]) opponentTeam

                            expectedForcingMoves =
                                [ { squareTo = Position.h8, squareFrom = Position.g8, value = Chess.CheckMate }
                                , { squareTo = Position.h7, squareFrom = Position.g7, value = Chess.CheckMate }
                                ]
                        in
                        Expect.equal expectedForcingMoves (Chess.forcingMoves game)

                --[ test "will lose material to achieve checkmate" <|
                ]
            ]
        , describe "check mate" <|
            [ describe "knows if check is counterable (block, take, escape)" <|
                [ test "no blocks, takes, or escape leads to checkmate" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.h1 monarch

                            attackers =
                                [ Chess.Occupied Position.g8 opponentRook
                                , Chess.Occupied Position.h7 opponentRook
                                ]

                            game =
                                Chess.init (attackers ++ [ current ]) team
                        in
                        Expect.true "Double rooks should be checkmating here." (Chess.isCheckmate game)
                , test "if escapable then not checkmate" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.h1 monarch

                            attackers =
                                [ Chess.Occupied Position.h7 opponentRook
                                ]

                            game =
                                Chess.init (attackers ++ [ current ]) team
                        in
                        Expect.false "Monarch may move out of check." (Chess.isCheckmate game)
                , test "if blockable then not checkmate" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.h1 monarch

                            attackers =
                                [ Chess.Occupied Position.g8 opponentRook
                                , Chess.Occupied Position.h7 opponentRook
                                ]

                            blocker =
                                Chess.Occupied Position.a2 rook

                            game =
                                Chess.init (attackers ++ [ current, blocker ]) team
                        in
                        Expect.false "Rook should be able to block." (Chess.isCheckmate game)
                , test "if capturable then not checkmate" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.h1 monarch

                            attackers =
                                [ Chess.Occupied Position.g8 opponentRook
                                , Chess.Occupied Position.h3 opponentRook
                                ]

                            taker =
                                Chess.Occupied Position.f5 bishop

                            game =
                                Chess.init (attackers ++ [ current, taker ]) team
                        in
                        Expect.false "Bishop should be able to capture the attacking Rook." (Chess.isCheckmate game)
                ]
            ]
        , describe "check" <|
            [ describe "knows if monarch is under fire" <|
                [ test "knows if any opposing piece may move to the monarchs square" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.b2 monarch

                            attackers =
                                [ Chess.Occupied Position.b1 opponentRook
                                , Chess.Occupied Position.c1 opponentBishop
                                , Chess.Occupied Position.a1 opponentAdvisor
                                ]

                            opponentThatCantAttack =
                                Chess.Occupied Position.h1 opponentRook

                            sameTeam =
                                Chess.Occupied Position.b3 rook

                            game =
                                Chess.init (attackers ++ [ current, opponentThatCantAttack, sameTeam ]) team
                        in
                        Expect.equal (List.sortBy position attackers) (List.sortBy position (Chess.findChecks game))
                ]
            ]
        , describe "canMoveTo" <|
            [ describe "single piece" <|
                [ test "monarch movement" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.b2 monarch

                            game =
                                Chess.init [ current ] team

                            validSquares =
                                [ Position.a1
                                , Position.a2
                                , Position.a3
                                , Position.b1
                                , Position.b3
                                , Position.c1
                                , Position.c2
                                , Position.c3
                                ]
                        in
                        Expect.true
                            "Knows monarch moves"
                            (List.all
                                (\pos -> Chess.canMoveTo pos game == [ Position.b2 ])
                                validSquares
                            )
                , test "monarch invalid moves" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.b2 monarch

                            game =
                                Chess.init [ current ] team

                            validSquares =
                                [ Position.a1
                                , Position.a2
                                , Position.a3
                                , Position.b1
                                , Position.b3
                                , Position.c1
                                , Position.c2
                                , Position.c3
                                ]

                            otherSquares =
                                List.filter (\s -> not (List.member s validSquares)) Position.all
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
                                Chess.Occupied Position.d4 bishop

                            game =
                                Chess.init [ current ] team
                        in
                        Expect.true
                            "Knows bishop moves"
                            (List.all
                                (\pos -> Chess.canMoveTo pos game == [ Position.d4 ])
                                diagonalMovesFromD4
                            )
                , test "bishop invalid moves" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.d4 bishop

                            game =
                                Chess.init [ current ] team

                            otherSquares =
                                List.filter (\s -> not (List.member s diagonalMovesFromD4)) Position.all
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
                                Chess.Occupied Position.d4 rook

                            game =
                                Chess.init [ current ] team
                        in
                        Expect.true
                            "Knows rook moves"
                            (List.all
                                (\pos -> Chess.canMoveTo pos game == [ Position.d4 ])
                                horizontalMovesFromD4
                            )
                , test "Rook invalid moves" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.d4 rook

                            game =
                                Chess.init [ current ] team

                            otherSquares =
                                List.filter (\s -> not (List.member s horizontalMovesFromD4)) Position.all
                        in
                        Expect.true
                            "Not valid rook movement"
                            (List.all
                                (\pos -> Chess.canMoveTo pos game == [])
                                otherSquares
                            )
                , test "Advisor movement" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.d4 advisor

                            game =
                                Chess.init [ current ] team
                        in
                        Expect.true
                            "Knows advisor moves"
                            (List.all
                                (\pos -> Chess.canMoveTo pos game == [ Position.d4 ])
                                (horizontalMovesFromD4 ++ diagonalMovesFromD4)
                            )
                , test "Advisor invalid moves" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.d4 advisor

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
                                    Position.all
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
                                Chess.Occupied Position.a1 advisor

                            friendly pos =
                                Chess.Occupied pos rook

                            opponent pos =
                                Chess.Occupied pos opponentRook

                            game =
                                Chess.init [ friendly Position.a2, current, friendly Position.b1, opponent Position.b2 ] team
                        in
                        Expect.equal [ Position.b2 ]
                            (List.filter
                                (\pos -> List.member Position.a1 (Chess.canMoveTo pos game))
                                Position.all
                            )
                , test "restrict movement by turn" <|
                    \() ->
                        let
                            current =
                                Chess.Occupied Position.a1 opponentAdvisor

                            game =
                                Chess.init [ current ] team
                        in
                        Expect.equal [] (Chess.canMoveTo Position.a2 game)
                , test "moves may not result in check" <|
                    \() ->
                        let
                            protected =
                                Chess.Occupied Position.a1 monarch

                            pinned =
                                Chess.Occupied Position.b1 advisor

                            pinner =
                                Chess.Occupied Position.c1 opponentAdvisor

                            game =
                                Chess.init [ protected, pinned, pinner ] team
                        in
                        Expect.equal [] (Chess.canMoveTo Position.b3 game)
                ]
            ]
        ]

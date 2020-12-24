module Chess.GameTest exposing (all)

import Chess.Game as Chess exposing (..)
import Expect exposing (..)
import Test exposing (..)


fullGame : Chess.Game
fullGame =
    init (Config White "KQkq" "-" 0 1)
        |> put (Piece Rook White) a1
        |> put (Piece Knight White) b1
        |> put (Piece Bishop White) c1
        |> put (Piece Hand White) d1
        |> put (Piece Monarch White) e1
        |> put (Piece Bishop White) f1
        |> put (Piece Knight White) g1
        |> put (Piece Rook White) h1
        |> put (Piece Pawn White) a2
        |> put (Piece Pawn White) b2
        |> put (Piece Pawn White) c2
        |> put (Piece Pawn White) d2
        |> put (Piece Pawn White) e2
        |> put (Piece Pawn White) f2
        |> put (Piece Pawn White) g2
        |> put (Piece Pawn White) h2
        |> put (Piece Pawn Black) a7
        |> put (Piece Pawn Black) b7
        |> put (Piece Pawn Black) c7
        |> put (Piece Pawn Black) d7
        |> put (Piece Pawn Black) e7
        |> put (Piece Pawn Black) f7
        |> put (Piece Pawn Black) g7
        |> put (Piece Pawn Black) h7
        |> put (Piece Rook Black) a8
        |> put (Piece Knight Black) b8
        |> put (Piece Bishop Black) c8
        |> put (Piece Hand Black) d8
        |> put (Piece Monarch Black) e8
        |> put (Piece Bishop Black) f8
        |> put (Piece Knight Black) g8
        |> put (Piece Rook Black) h8


all : Test
all =
    describe "Chess"
        [ describe "toFen" <|
            [ test "Will output a FEN of the current state" <|
                \() ->
                    fullGame
                        |> toFen
                        |> Expect.equal (Fen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
            ]

        --            let
        --                team =
        --                    Chess.Black
        --
        --                monarch =
        --                    Chess.Monarch team
        --
        --                current =
        --                    Chess.Occupied Chess.b2 monarch
        --
        --                game =
        --                    Chess.init [ current ] team
        --
        --                validSquares =
        --                    [ Chess.a1
        --                    , Chess.a2
        --                    , Chess.a3
        --                    , Chess.b1
        --                    , Chess.b3
        --                    , Chess.c1
        --                    , Chess.c2
        --                    , Chess.c3
        --                    ]
        --            in
        --            Expect.true
        --                "Knows monarch moves"
        --                (List.all
        --                    (\pos -> Chess.canMoveTo pos game == [ Chess.b2 ])
        --                    validSquares
        --                )
        --    , test "invalid moves" <|
        --        \() ->
        --            let
        --                team =
        --                    Chess.Black
        --
        --                monarch =
        --                    Chess.Monarch team
        --
        --                current =
        --                    Chess.Occupied Chess.b2 monarch
        --
        --                game =
        --                    Chess.init [ current ] team
        --
        --                validSquares =
        --                    [ Chess.a1
        --                    , Chess.a2
        --                    , Chess.a3
        --                    , Chess.b1
        --                    , Chess.b3
        --                    , Chess.c1
        --                    , Chess.c2
        --                    , Chess.c3
        --                    ]
        --
        --                otherSquares =
        --                    List.filter (\s -> not (List.member s validSquares)) Chess.all
        --            in
        --            Expect.true
        --                "Not valid monarch movement"
        --                (List.all
        --                    (\pos -> Chess.canMoveTo pos game == [])
        --                    otherSquares
        --                )
        --validSquares [ Chess.a1 ]
        --, test "multi" <|
        --    \() ->
        --        let
        --            team =
        --                Chess.Black
        --
        --            monarch =
        --                Chess.Monarch team
        --
        --            current =
        --                Chess.Occupied Chess.a1 monarch
        --
        --            game =
        --                Chess.init [ current ] team
        --
        --            validSquares =
        --                Chess.canMoveTo Chess.a2 game
        --        in
        --        Expect.equal validSquares [ Chess.a1 ]
        ]

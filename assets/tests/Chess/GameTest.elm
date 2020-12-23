module Chess.GameTest exposing (all)

import Chess.Game as Chess
import Expect exposing (..)
import Test exposing (..)


all : Test
all =
    describe "Chess"
        [ describe "canMoveTo" <|
            [ test "single piece" <|
                \() ->
                    Expect.equal true true
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

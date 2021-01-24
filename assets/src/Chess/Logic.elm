module Chess.Logic exposing
    ( Piece(..)
    , PieceType(..)
    , Square(..)
    , Team(..)
    , canMoveTo
    , findChecks
    , init
    )

import Chess.Position as Position exposing (Position(..))
import Dict exposing (Dict)


type Team
    = Black
    | White


type PieceType
    = Monarch
    | Advisor
    | Bishop
    | Rook


type Piece
    = Piece PieceType Team


type Square
    = Occupied Position Piece


type alias Game =
    -- TODO: Extract OccupiedSquares into new location (so that data structure used is opaque).
    -- Provide appropriate accessors / map functions.
    { occupiedSquares : Dict ( Int, Int ) Piece
    , turn : Team
    }



--            team = Chess.Black
--            monarch = Chess.Monarch team
--            squareFrom = Chess.Square Chess.A1 monarch
--            squareTo = Chess.Square Chess.A2 Nothing
--            game = Chess.init [square]
-- Square accessor functions


positionToSquareKey : Position -> ( Int, Int )
positionToSquareKey (Position column row) =
    ( column, row )


asht (Occupied position piece) b =
    Dict.insert (positionToSquareKey position) piece b


init : List Square -> Team -> Game
init squares turn =
    Game (List.foldl asht Dict.empty squares) turn



-- FORCING MOVES
-- CHECK
--type alias Game =
--    -- TODO: Extract OccupiedSquares into new location (so that data structure used is opaque).
--    -- Provide appropriate accessors / map functions.
--    { occupiedSquares : Dict ( Int, Int ) Piece
--    , turn : Team
--    }


findChecks : Game -> List Square
findChecks { occupiedSquares, turn } =
    let
        occupiedAsList =
            Dict.toList occupiedSquares

        ( monarchLocation, monarch ) =
            List.filter (sameTeam turn) occupiedAsList
                |> List.filter isMonarch
                |> List.head
                |> Maybe.withDefault ( ( 1, 1 ), Piece Monarch turn )

        enemyTeam =
            List.filter (opponentTeam turn) occupiedAsList

        fromTuple ( a, b ) fn =
            fn a b
    in
    List.filter (\( pieceLocation, p ) -> pieceCanMoveTo (fromTuple monarchLocation Position) occupiedSquares pieceLocation) enemyTeam
        |> List.map (\( pos, piece ) -> Occupied (fromTuple pos Position) piece)


isMonarch : ( a, Piece ) -> Bool
isMonarch ( _, Piece pieceType _ ) =
    case pieceType of
        Monarch ->
            True

        _ ->
            False


sameTeam : Team -> ( a, Piece ) -> Bool
sameTeam turn ( _, Piece _ pieceColor ) =
    pieceColor == turn


opponentTeam : Team -> ( a, Piece ) -> Bool
opponentTeam turn ( _, Piece _ pieceColor ) =
    pieceColor /= turn



-- MOVEMENT


pieceCanMoveTo : Position -> Dict ( Int, Int ) Piece -> ( Int, Int ) -> Bool
pieceCanMoveTo moveTo occupiedSquares occupied =
    case Dict.get occupied occupiedSquares of
        Nothing ->
            Debug.todo "impossible given the inkoking code"

        Just (Piece Monarch _) ->
            monarchCanMoveTo moveTo occupiedSquares occupied

        Just (Piece Advisor team) ->
            canMoveToRepeating moveTo occupiedSquares occupied team (horizontalMovement ++ diagonalMovement)

        Just (Piece Bishop team) ->
            canMoveToRepeating moveTo occupiedSquares occupied team diagonalMovement

        Just (Piece Rook team) ->
            canMoveToRepeating moveTo occupiedSquares occupied team horizontalMovement


canMoveTo : Position -> Game -> List Position
canMoveTo moveTo { occupiedSquares, turn } =
    let
        allOccupied =
            Dict.keys occupiedSquares
    in
    List.filter (pieceCanMoveTo moveTo occupiedSquares) allOccupied
        |> List.map (\( x, y ) -> Position x y)


monarchCanMoveTo : Position -> Dict ( Int, Int ) Piece -> ( Int, Int ) -> Bool
monarchCanMoveTo moveTo occupiedSquares occupied =
    List.any (\vector -> checkMoveInDirection vector moveTo occupiedSquares occupied)
        (horizontalMovement ++ diagonalMovement)


canMoveToRepeating : Position -> Dict ( Int, Int ) Piece -> ( Int, Int ) -> Team -> List ( Int, Int ) -> Bool
canMoveToRepeating moveTo occupiedSquares occupied team =
    List.any (\vector -> checkMoveInDirectionRepeating vector moveTo occupiedSquares occupied team)


horizontalMovement =
    [ west
    , east
    , north
    , south
    ]


diagonalMovement =
    [ northWest
    , northEast
    , southWest
    , southEast
    ]


west =
    ( -1, 0 )


east =
    ( 1, 0 )


north =
    ( 0, 1 )


south =
    ( 0, -1 )


moveOne : Int -> Int -> Position -> Dict ( Int, Int ) Piece -> ( Int, Int ) -> Bool
moveOne columnDelta rowDeltay (Position col row) occupiedSquares ( currentColumn, currentRow ) =
    ( columnDelta + currentColumn, rowDeltay + currentRow ) == ( col, row )


northEast =
    ( 1, 1 )


southWest =
    ( -1, -1 )


southEast =
    ( -1, 1 )


northWest =
    ( 1, -1 )


checkMoveInDirection : ( Int, Int ) -> Position -> Dict ( Int, Int ) Piece -> ( Int, Int ) -> Bool
checkMoveInDirection ( columnDelta, rowDeltay ) (Position column row) occupiedSquares ( currentColumn, currentRow ) =
    let
        nextColumn =
            columnDelta + currentColumn

        nextRow =
            rowDeltay + currentRow
    in
    if nextColumn == 0 || nextRow == 0 || nextColumn == 9 || nextRow == 9 then
        False

    else
        ( nextColumn, nextRow ) == ( column, row )



--all : List Position
--all =
--    [ a8
--    , b8
--    , c8
--    , d8
--    , e8
--    , f8
--    , g8
--    , h8
--    , a7
--    , b7
--    , c7
--    , d7
--    , e7
--    , f7
--    , g7
--    , h7
--    , a6
--    , b6
--    , c6
--    , d6
--    , e6
--    , f6
--    , g6
--    , h6
--    , a5
--    , b5
--    , c5
--    , d5
--    , e5
--    , f5
--    , g5
--    , h5
--    , a4
--    , b4
--    , c4
--    , d4
--    , e4
--    , f4
--    , g4
--    , h4
--    , a3
--    , b3
--    , c3
--    , d3
--    , e3
--    , f3
--    , g3
--    , h3
--    , a2
--    , b2
--    , c2
--    , d2
--    , e2
--    , f2
--    , g2
--    , h2
--    , a1
--    , b1
--    , c1
--    , d1
--    , e1
--    , f1
--    , g1
--    , h1
--    ]
--checkMoveInDirectionRepeating : ( Int, Int ) -> Position -> Dict ( Int, Int ) Piece -> ( Int, Int ) -> Bool
--checkMoveInDirectionRepeating ( columnDelta, rowDeltay ) (Position column row) occupiedSquares ( currentColumn, currentRow ) =
--    let
--        nextColumn =
--            columnDelta + currentColumn
--
--        nextRow =
--            rowDeltay + currentRow
--    in
--    if nextColumn == 0 || nextRow == 0 || nextColumn == 9 || nextRow == 9 then
--        False
--
--    else if ( nextColumn, nextRow ) == ( column, row ) then
--        True
--
--    else
--        checkMoveInDirectionRepeating ( columnDelta, rowDeltay ) (Position column row) occupiedSquares ( nextColumn, nextRow )


checkMoveInDirectionRepeating : ( Int, Int ) -> Position -> Dict ( Int, Int ) Piece -> ( Int, Int ) -> Team -> Bool
checkMoveInDirectionRepeating ( columnDelta, rowDeltay ) (Position column row) occupiedSquares ( currentColumn, currentRow ) team =
    let
        nextColumn =
            columnDelta + currentColumn

        nextRow =
            rowDeltay + currentRow

        piece =
            Dict.get ( nextColumn, nextRow ) occupiedSquares
    in
    if nextColumn == 0 || nextRow == 0 || nextColumn == 9 || nextRow == 9 then
        False

    else if ( nextColumn, nextRow ) == ( column, row ) && not (occupiedByFriendly piece team) then
        True

    else if occupiedSquare piece then
        False

    else
        checkMoveInDirectionRepeating ( columnDelta, rowDeltay ) (Position column row) occupiedSquares ( nextColumn, nextRow ) team


occupiedSquare : Maybe Piece -> Bool
occupiedSquare piece =
    case piece of
        Nothing ->
            False

        Just (Piece _ t) ->
            True


occupiedByFriendly : Maybe Piece -> Team -> Bool
occupiedByFriendly piece team =
    case piece of
        Nothing ->
            False

        Just (Piece _ t) ->
            t == team

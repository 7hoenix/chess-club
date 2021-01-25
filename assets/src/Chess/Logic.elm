module Chess.Logic exposing
    ( Piece(..)
    , PieceType(..)
    , Square(..)
    , Team(..)
    , canMoveTo
    , findChecks
    , init
    , isCheckmate
    )

import Chess.Position exposing (Position(..))
import Dict exposing (Dict)
import Set exposing (Set)


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


makeMove : ( Int, Int ) -> ( Int, Int ) -> Game -> Game
makeMove squareFrom squareTo ({ occupiedSquares, turn } as game) =
    case Dict.get squareFrom occupiedSquares of
        Nothing ->
            game

        Just piece ->
            Dict.remove squareFrom occupiedSquares
                |> Dict.insert squareTo piece
                |> (\updatedPieces -> { game | occupiedSquares = updatedPieces, turn = opponentTurn turn })


positionToSquareKey : Position -> ( Int, Int )
positionToSquareKey (Position column row) =
    ( column, row )


asht (Occupied position piece) b =
    Dict.insert (positionToSquareKey position) piece b


init : List Square -> Team -> Game
init squares turn =
    Game (List.foldl asht Dict.empty squares) turn



-- FORCING MOVES
-- CHECKMATE


isCheckmate : Game -> Bool
isCheckmate ({ occupiedSquares, turn } as game) =
    case findChecks game of
        [] ->
            False

        checks ->
            let
                occupiedAsList =
                    Dict.toList occupiedSquares

                -- TODO: pass in monarchs so that we know we have them.
                ( monarchLocation, monarch ) =
                    List.filter (sameTeam turn) occupiedAsList
                        |> List.filter isMonarch
                        |> List.head
                        |> Maybe.withDefault ( ( 1, 1 ), Piece Monarch turn )

                monarchVectors =
                    possibleMonarchVectors monarchLocation

                monarchIsAbleToEscape =
                    List.filter (\monarchMoveTo -> monarchCanMoveTo game monarchMoveTo occupiedSquares monarchLocation) monarchVectors
                        |> List.isEmpty
                        |> not
            in
            monarchIsAbleToEscape
                || checksAreBlockable monarchLocation game checks
                || checksAreCapturable game checks
                |> not



-- TODO: type Checks = SingleCheck | DoubleCheck?


checksAreCapturable : Game -> List Square -> Bool
checksAreCapturable game checks =
    case checks of
        check :: [] ->
            checkIsCapturable game check

        checkA :: checkB :: _ ->
            -- Cannot escape double check by capturing!
            False

        _ ->
            -- No checks means no problems.
            True


checkIsCapturable : Game -> Square -> Bool
checkIsCapturable game (Occupied position piece) =
    canMoveTo position game
        |> List.isEmpty
        |> not


checksAreBlockable : ( Int, Int ) -> Game -> List Square -> Bool
checksAreBlockable monarchSquare game checks =
    case checks of
        -- NOTE: in Chess the maximum number of checks is 2.
        -- In Chinese Xiang Xi it is possible to have 3 or even 4 checks.
        check :: remainingChecks ->
            List.map (checkBlockable monarchSquare game) remainingChecks
                -- NOTE: This is certainly more complex than it needs to be. Future you, I owe you a beer.
                |> List.foldl Set.intersect (checkBlockable monarchSquare game check)
                |> Set.isEmpty
                |> not

        _ ->
            -- No checks means no problems.
            True


checkBlockable : ( Int, Int ) -> Game -> Square -> Set ( Int, Int )
checkBlockable ( monarchColumn, monarchRow ) ({ occupiedSquares } as game) (Occupied (Position checkingColumn checkingRow) checkingPiece) =
    pieceMovementToPath (Position monarchColumn monarchRow) occupiedSquares ( checkingColumn, checkingRow )
        |> List.map (\( routeSquareColumn, routeSquareRow ) -> canMoveTo (Position routeSquareColumn routeSquareRow) game)
        |> List.map (List.map (\(Position c r) -> ( c, r )))
        |> List.map Set.fromList
        |> List.foldl Set.union Set.empty


possibleMonarchVectors : ( Int, Int ) -> List Position
possibleMonarchVectors ( px, py ) =
    List.map (\( dx, dy ) -> ( dx + px, dy + py )) (horizontalMovement ++ diagonalMovement)
        |> List.filter (\( newColumn, newRow ) -> newColumn >= 1 && newColumn <= 8 && newRow >= 1 && newRow <= 8)
        |> List.map (\( a, b ) -> Position a b)



-- CHECK


findChecks : Game -> List Square
findChecks ({ occupiedSquares, turn } as game) =
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
    List.filter (\( pieceLocation, p ) -> pieceCanMoveTo { game | turn = opponentTurn turn } (fromTuple monarchLocation Position) occupiedSquares (opponentTurn turn) pieceLocation) enemyTeam
        |> List.map (\( pos, piece ) -> Occupied (fromTuple pos Position) piece)


opponentTurn : Team -> Team
opponentTurn turn =
    case turn of
        Black ->
            White

        White ->
            Black


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


pieceMovementToPath : Position -> Dict ( Int, Int ) Piece -> ( Int, Int ) -> List ( Int, Int )
pieceMovementToPath moveTo occupiedSquares occupied =
    case Dict.get occupied occupiedSquares of
        Nothing ->
            []

        Just (Piece Monarch _) ->
            []

        Just (Piece Advisor team) ->
            findPath moveTo occupiedSquares occupied team [] (horizontalMovement ++ diagonalMovement)

        Just (Piece Bishop team) ->
            findPath moveTo occupiedSquares occupied team [] diagonalMovement

        Just (Piece Rook team) ->
            findPath moveTo occupiedSquares occupied team [] horizontalMovement


pieceCanMoveTo : Game -> Position -> Dict ( Int, Int ) Piece -> Team -> ( Int, Int ) -> Bool
pieceCanMoveTo game ((Position squareToColumn squareToRow) as moveTo) occupiedSquares turn occupied =
    -- TODO: dry plz <- Should be a (Result MoveError Bool)
    -- type MoveError = NoPieceOnSquare | OpponentsPiece | ResultsInCheck
    case Dict.get occupied occupiedSquares of
        Nothing ->
            False

        Just piece ->
            case piece of
                Piece Monarch team ->
                    monarchCanMoveTo game moveTo occupiedSquares occupied

                Piece Advisor team ->
                    canMoveToRepeating game moveTo occupiedSquares occupied team (horizontalMovement ++ diagonalMovement)

                Piece Bishop team ->
                    canMoveToRepeating game moveTo occupiedSquares occupied team diagonalMovement

                Piece Rook team ->
                    canMoveToRepeating game moveTo occupiedSquares occupied team horizontalMovement


doesNotLeadToCheck : ( Int, Int ) -> ( Int, Int ) -> Game -> Bool
doesNotLeadToCheck squareFrom squareTo game =
    makeMove squareFrom squareTo game
        |> (\virtualGame ->
                { virtualGame | turn = game.turn }
                    |> findChecks
                    |> List.isEmpty
           )


canMoveTo : Position -> Game -> List Position
canMoveTo moveTo ({ occupiedSquares, turn } as game) =
    let
        allOccupied =
            Dict.keys occupiedSquares
    in
    List.filter (pieceCanMoveTo game moveTo occupiedSquares turn) allOccupied
        |> List.map (\( x, y ) -> Position x y)


monarchCanMoveTo : Game -> Position -> Dict ( Int, Int ) Piece -> ( Int, Int ) -> Bool
monarchCanMoveTo game ((Position squareToColumn squareToRow) as moveTo) occupiedSquares occupied =
    List.any (\vector -> checkMoveInDirection vector moveTo occupiedSquares occupied)
        (horizontalMovement ++ diagonalMovement)
        && doesNotLeadToCheck occupied ( squareToColumn, squareToRow ) game


canMoveToRepeating : Game -> Position -> Dict ( Int, Int ) Piece -> ( Int, Int ) -> Team -> List ( Int, Int ) -> Bool
canMoveToRepeating ({ turn } as game) ((Position squareToColumn squareToRow) as moveTo) occupiedSquares occupied team vectors =
    turn
        == team
        && List.any (\vector -> checkMoveInDirectionRepeating vector moveTo occupiedSquares occupied team) vectors
        && doesNotLeadToCheck occupied ( squareToColumn, squareToRow ) game


findPath : Position -> Dict ( Int, Int ) Piece -> ( Int, Int ) -> Team -> List ( Int, Int ) -> List ( Int, Int ) -> List ( Int, Int )
findPath moveTo occupiedSquares occupied team currentPath vectors =
    let
        final =
            List.map (\vector -> findPathRepeating vector moveTo occupiedSquares occupied team currentPath) vectors

        removeEmpties =
            List.filter (\l -> not (List.isEmpty l)) final
    in
    case removeEmpties of
        [] ->
            []

        p :: [] ->
            p

        _ ->
            -- You should never be able to have two paths to the same square.
            []


findPathRepeating : ( Int, Int ) -> Position -> Dict ( Int, Int ) Piece -> ( Int, Int ) -> Team -> List ( Int, Int ) -> List ( Int, Int )
findPathRepeating ( columnDelta, rowDeltay ) (Position column row) occupiedSquares ( currentColumn, currentRow ) team currentPath =
    let
        nextColumn =
            columnDelta + currentColumn

        nextRow =
            rowDeltay + currentRow

        piece =
            Dict.get ( nextColumn, nextRow ) occupiedSquares

        nextPath =
            ( nextColumn, nextRow ) :: currentPath
    in
    if nextColumn == 0 || nextRow == 0 || nextColumn == 9 || nextRow == 9 then
        []

    else if ( nextColumn, nextRow ) == ( column, row ) && not (occupiedByFriendly piece team) then
        nextPath

    else if occupiedSquare piece then
        []

    else
        findPathRepeating ( columnDelta, rowDeltay ) (Position column row) occupiedSquares ( nextColumn, nextRow ) team nextPath


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

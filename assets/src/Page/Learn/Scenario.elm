module Page.Learn.Scenario exposing
    ( Move
    , Scenario
    , getScenario
    , makeMove
    , moveSelection
    , scenarioSelection
    )

import Api.Mutation as Mutation
import Api.Object
import Api.Object.Move
import Api.Object.Scenario exposing (availableMoves, currentState, id)
import Api.Query exposing (scenario)
import Api.Scalar exposing (Id(..))
import Api.ScalarCodecs exposing (Id)
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, list, with)



-- SCENARIO


type alias Scenario =
    { availableMoves : List Move
    , currentState : String
    , id : Id
    }


query : String -> SelectionSet Scenario RootQuery
query id =
    (scenario <| { scenarioId = Id id }) scenarioSelection


scenarioSelection : SelectionSet Scenario Api.Object.Scenario
scenarioSelection =
    SelectionSet.map3 Scenario
        (availableMoves moveSelection)
        currentState
        id


getScenario : String -> String -> (Result (Graphql.Http.Error Scenario) Scenario -> msg) -> Cmd msg
getScenario backendEndpoint id msg =
    query id
        |> Graphql.Http.queryRequest (backendEndpoint ++ "/api/graphql")
        |> Graphql.Http.send msg



-- MOVE


type alias Move =
    { fenAfterMove : String
    , squareFrom : String
    , squareTo : String
    , color : String
    , moveCommand : String
    }


moveSelection : SelectionSet Move Api.Object.Move
moveSelection =
    SelectionSet.succeed Move
        |> with Api.Object.Move.fenAfterMove
        |> with Api.Object.Move.squareFrom
        |> with Api.Object.Move.squareTo
        |> with Api.Object.Move.color
        |> with Api.Object.Move.moveCommand



-- This only sends as we are subscribing to the result


sendMakeMove : Move -> SelectionSet () RootMutation
sendMakeMove { moveCommand } =
    Mutation.makeMove { moveCommand = moveCommand, scenarioId = Api.Scalar.Id "1" } SelectionSet.empty
        |> SelectionSet.map (\_ -> ())


makeMove : String -> Move -> (Result (Graphql.Http.Error ()) () -> msg) -> Cmd msg
makeMove backendEndpoint move msg =
    sendMakeMove move
        |> Graphql.Http.mutationRequest (backendEndpoint ++ "/api/graphql")
        |> Graphql.Http.send msg

module Page.Learn.Scenario exposing
    ( Move
    , Scenario
    , ScenarioSeed
    , createScenario
    , getScenario
    , getScenarios
    , makeMove
    , moveSelection
    , scenarioSelection
    , subscribeToMoves
    )

import Api.Mutation as Mutation
import Api.Object
import Api.Object.Move
import Api.Object.Scenario exposing (availableMoves, currentState, id)
import Api.Query exposing (scenario, scenarios)
import Api.Scalar exposing (Id(..))
import Api.Subscription as Subscription
import Graphql.Http exposing (Request)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, list, with)



-- SCENARIO


type alias Scenario =
    { availableMoves : List Move
    , currentState : String
    , id : Id
    }


scenarioQuery : Id -> SelectionSet Scenario RootQuery
scenarioQuery id =
    (scenario <| { scenarioId = id }) scenarioSelection


scenarioSelection : SelectionSet Scenario Api.Object.Scenario
scenarioSelection =
    SelectionSet.map3 Scenario
        (availableMoves moveSelection)
        currentState
        id


getScenario : String -> Id -> (Result (Graphql.Http.Error Scenario) Scenario -> msg) -> Cmd msg
getScenario backendEndpoint id msg =
    sendQuery backendEndpoint (scenarioQuery id) msg



-- SCENARIO SEEDS


type alias ScenarioSeed =
    { id : Id
    }


scenariosQuery : SelectionSet (List ScenarioSeed) RootQuery
scenariosQuery =
    scenarios scenarioSeedSelection


scenarioSeedSelection : SelectionSet ScenarioSeed Api.Object.Scenario
scenarioSeedSelection =
    SelectionSet.map ScenarioSeed
        id


getScenarios : String -> (Result (Graphql.Http.Error (List ScenarioSeed)) (List ScenarioSeed) -> msg) -> Cmd msg
getScenarios backendEndpoint msg =
    sendQuery backendEndpoint scenariosQuery msg



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


sendMakeMove : Id -> Move -> SelectionSet () RootMutation
sendMakeMove id { moveCommand } =
    Mutation.makeMove { moveCommand = moveCommand, scenarioId = id } SelectionSet.empty
        |> SelectionSet.map (\_ -> ())


makeMove : String -> Id -> Move -> (Result (Graphql.Http.Error ()) () -> msg) -> Cmd msg
makeMove backendEndpoint id move msg =
    sendMutation backendEndpoint (sendMakeMove id move) msg



-- SUBSCRIBE TO MOVES


subscribeToMoves : Id -> SelectionSet Scenario RootSubscription
subscribeToMoves id =
    Subscription.moveMade { scenarioId = id } scenarioSelection



-- CREATE SCENARIO


createScenarioMutation : SelectionSet Id RootMutation
createScenarioMutation =
    Mutation.createScenario id


createScenario : String -> (Result (Graphql.Http.Error Id) Id -> msg) -> Cmd msg
createScenario backendEndpoint msg =
    sendMutation backendEndpoint createScenarioMutation msg



-- GENERIC


sendQuery : String -> SelectionSet decodesTo RootQuery -> (Result (Graphql.Http.Error decodesTo) decodesTo -> msg) -> Cmd msg
sendQuery backendEndpoint sender msg =
    sender
        |> Graphql.Http.queryRequest (backendEndpoint ++ "/api/graphql")
        |> Graphql.Http.send msg


sendMutation : String -> SelectionSet decodesTo RootMutation -> (Result (Graphql.Http.Error decodesTo) decodesTo -> msg) -> Cmd msg
sendMutation backendEndpoint sender msg =
    sender
        |> Graphql.Http.mutationRequest (backendEndpoint ++ "/api/graphql")
        |> Graphql.Http.send msg

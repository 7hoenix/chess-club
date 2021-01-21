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
import Backend exposing (Backend)
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


getScenario : Backend -> Id -> (Result (Graphql.Http.Error Scenario) Scenario -> msg) -> Cmd msg
getScenario backend id msg =
    sendQuery backend (scenarioQuery id) msg



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


getScenarios : Backend -> (Result (Graphql.Http.Error (List ScenarioSeed)) (List ScenarioSeed) -> msg) -> Cmd msg
getScenarios backend msg =
    sendQuery backend scenariosQuery msg



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


makeMove : Backend -> Id -> Move -> (Result (Graphql.Http.Error ()) () -> msg) -> Cmd msg
makeMove backend id move msg =
    sendMutation backend (sendMakeMove id move) msg



-- SUBSCRIBE TO MOVES


subscribeToMoves : Id -> SelectionSet Scenario RootSubscription
subscribeToMoves id =
    Subscription.moveMade { scenarioId = id } scenarioSelection



-- CREATE SCENARIO


createScenarioMutation : SelectionSet Id RootMutation
createScenarioMutation =
    Mutation.createScenario id


createScenario : Backend -> (Result (Graphql.Http.Error Id) Id -> msg) -> Cmd msg
createScenario backend msg =
    sendMutation backend createScenarioMutation msg



-- GENERIC


sendQuery : Backend -> SelectionSet decodesTo RootQuery -> (Result (Graphql.Http.Error decodesTo) decodesTo -> msg) -> Cmd msg
sendQuery backend sender msg =
    sender
        |> Graphql.Http.queryRequest (backend.endpoint ++ "/api/graphql")
        |> Graphql.Http.withHeader "authorization" ("Bearer " ++ Backend.getAuthToken backend.authToken)
        |> Graphql.Http.send msg


sendMutation : Backend -> SelectionSet decodesTo RootMutation -> (Result (Graphql.Http.Error decodesTo) decodesTo -> msg) -> Cmd msg
sendMutation backend sender msg =
    sender
        |> Graphql.Http.mutationRequest (backend.endpoint ++ "/api/graphql")
        |> Graphql.Http.withHeader "authorization" ("Bearer " ++ Backend.getAuthToken backend.authToken)
        |> Graphql.Http.send msg

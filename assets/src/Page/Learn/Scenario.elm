module Page.Learn.Scenario exposing
    ( Move
    , Scenario
    , getScenarios
    , makeMove
    , moveSelection
    )

import Api.Mutation as Mutation
import Api.Object
import Api.Object.Move
import Api.Object.Scenario exposing (id, startingState)
import Api.Query exposing (scenarios)
import Api.Scalar
import Api.ScalarCodecs exposing (Id)
import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)



-- SCENARIO


type alias Scenario =
    { startingState : String
    , id : Id
    }


query : SelectionSet (List Scenario) RootQuery
query =
    scenarios scenarioSelection


scenarioSelection : SelectionSet Scenario Api.Object.Scenario
scenarioSelection =
    SelectionSet.map2 Scenario
        startingState
        id


getScenarios : String -> (Result (Graphql.Http.Error (List Scenario)) (List Scenario) -> msg) -> Cmd msg
getScenarios backendEndpoint msg =
    query
        |> Graphql.Http.queryRequest (backendEndpoint ++ "/api/graphql")
        |> Graphql.Http.send msg



-- MOVE


type alias Move =
    { squareFrom : String
    , squareTo : String
    }


moveSelection : SelectionSet Move Api.Object.Move
moveSelection =
    SelectionSet.succeed Move
        |> with Api.Object.Move.squareFrom
        |> with Api.Object.Move.squareTo



-- This only sends as we are subscribing to the result


sendMakeMove : String -> String -> SelectionSet () RootMutation
sendMakeMove from to =
    Mutation.makeMove { squareFrom = from, squareTo = to, scenarioId = Api.Scalar.Id "1" } SelectionSet.empty
        |> SelectionSet.map (\_ -> ())


makeMove : String -> String -> String -> (Result (Graphql.Http.Error ()) () -> msg) -> Cmd msg
makeMove backendEndpoint from to msg =
    sendMakeMove from to
        |> Graphql.Http.mutationRequest (backendEndpoint ++ "/api/graphql")
        |> Graphql.Http.send msg

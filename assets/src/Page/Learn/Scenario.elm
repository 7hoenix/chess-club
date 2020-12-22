module Page.Learn.Scenario exposing
    ( Scenario
    , getScenarios
    )

import Api.Object
import Api.Object.Scenario exposing (id, startingState)
import Api.Query exposing (scenarios)
import Api.ScalarCodecs exposing (Id)
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)



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

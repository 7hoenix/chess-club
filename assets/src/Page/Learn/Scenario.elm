module Page.Learn.Scenario exposing
    ( Scenario
    , getScenarios
    )

import Api.Object
import Api.Object.Scenario exposing (id, startingState)
import Api.Query as Query exposing (scenarios)
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



--|> SelectionSet.list


scenarioSelection : SelectionSet Scenario Api.Object.Scenario
scenarioSelection =
    SelectionSet.map2 Scenario
        startingState
        id


getScenarios : (Result (Graphql.Http.Error (List Scenario)) (List Scenario) -> msg) -> Cmd msg
getScenarios msg =
    query
        |> Graphql.Http.queryRequest "http://localhost:4000/api/graphql"
        |> Graphql.Http.send msg

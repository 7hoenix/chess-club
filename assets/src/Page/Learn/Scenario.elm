module Page.Learn.Scenario exposing
    ( Scenario
    , getScenarios
    )

import Api.Object.Scenario as Scenario exposing (startingState)
import Api.Query as Query exposing (scenarios)
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)



-- SCENARIO


type alias Scenario =
    { startingState : String
    }


getScenarios : (Result (Graphql.Http.Error (List Scenario)) (List Scenario) -> msg) -> Cmd msg
getScenarios msg =
    scenarios (startingState |> SelectionSet.map Scenario)
        |> Graphql.Http.queryRequest "http://localhost:4000/api/graphql"
        |> Graphql.Http.send msg

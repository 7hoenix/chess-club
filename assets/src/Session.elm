module Session exposing
    ( Data
    , addScenarios
    , empty
    , getScenarios
    )

import Page.Learn.Scenario as Scenario



-- SESSION DATA


type alias Data =
    { scenarios : Maybe (List Scenario.Scenario)
    , backendEndpoint : String
    }


empty : String -> Data
empty backendEndpoint =
    Data Nothing backendEndpoint



-- SCENARIOS


getScenarios : Data -> Maybe (List Scenario.Scenario)
getScenarios data =
    data.scenarios


addScenarios : List Scenario.Scenario -> Data -> Data
addScenarios scenarios data =
    { data | scenarios = Just scenarios }

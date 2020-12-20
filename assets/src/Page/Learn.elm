module Page.Learn exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Graphql.Http
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Lazy exposing (..)
import Page.Learn.Scenario as Scenario
import Page.Problem as Problem
import Session
import Skeleton



-- MODEL


type alias Model =
    { session : Session.Data
    , scenarios : Scenarios
    }


type Scenarios
    = Failure
    | Loading
    | Success (List Scenario.Scenario)


init : Session.Data -> ( Model, Cmd Msg )
init session =
    case Session.getScenarios session of
        Just entries ->
            ( Model session (Success entries)
            , Cmd.none
            )

        Nothing ->
            ( Model session Loading
            , Scenario.getScenarios session.backendEndpoint GotScenarios
            )



-- UPDATE


type Msg
    = GotScenarios (Result (Graphql.Http.Error (List Scenario.Scenario)) (List Scenario.Scenario))


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        GotScenarios result ->
            case result of
                Err _ ->
                    ( { model | scenarios = Failure }
                    , Cmd.none
                    )

                Ok scenarios ->
                    ( { model
                        | scenarios = Success scenarios
                        , session = Session.addScenarios scenarios model.session
                      }
                    , Cmd.none
                    )



-- VIEW


view : Model -> Skeleton.Details Msg
view model =
    { title = "Learn"
    , header = []
    , warning = Skeleton.NoProblems
    , attrs = [ class "container mx-auto px-4" ]
    , children =
        [ lazy viewLearn model.scenarios
        ]
    }



-- VIEW LEARN


viewLearn : Scenarios -> Html Msg
viewLearn scenarios =
    div [ class "p-6 max-w-sm mx-auto bg-white rounded-xl shadow-md flex items-center" ]
        [ case scenarios of
            Failure ->
                div Problem.styles (Problem.offline "scenarios.json")

            Loading ->
                text ""

            -- TODO handle multiple scenarios.
            Success (scenario :: _) ->
                div []
                    [ viewScenario scenario
                    ]

            Success _ ->
                div [ class "flex-shrink-0 text-xl font-medium text-purple-600" ]
                    [ text "You don't seem to have any scenarios." ]
        ]



-- VIEW SCENARIO


viewScenario : Scenario.Scenario -> Html msg
viewScenario scenario =
    div []
        [ h3 [] [ text "Scenario Starting state" ]
        , p [ class "starting-state" ] [ text scenario.startingState ]
        , viewBoard
        ]


viewBoard : Html msg
viewBoard =
    div [ class "grid grid-rows-8 grid-flow-col gap-1" ]
        (List.concat (List.map viewRow (List.reverse (List.range 1 8))))



--viewBoard : Html msg
--viewBoard =
--    div [ class "grid grid-cols-8 gap-1" ]
--        (List.concat (List.map viewRow (List.reverse (List.range 1 8))))


viewRow : Int -> List (Html msg)
viewRow row =
    List.map (viewCell row) (List.range 1 8)


viewCell : Int -> Int -> Html msg
viewCell row column =
    div [ class "bg-gray-300 rounded-md flex items-center justify-center text-2xl font-extrabold " ]
        [ text <| getLetter column ++ " " ++ String.fromInt row ]


getLetter : Int -> String
getLetter i =
    case i of
        1 ->
            "a"

        2 ->
            "b"

        3 ->
            "c"

        4 ->
            "d"

        5 ->
            "e"

        6 ->
            "f"

        7 ->
            "g"

        8 ->
            "h"

        _ ->
            "NOT VALID"

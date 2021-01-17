module Page.Learn exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Api.Scalar exposing (Id)
import Chess.Game
import Graphql.Document
import Graphql.Http
import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Html.Lazy exposing (..)
import Js
import Json.Decode
import Page.Learn.Scenario as Scenario exposing (Move, scenarioSelection, subscribeToMoves)
import Prelude exposing (Segment(..))
import Session
import Skeleton



-- MODEL


type alias Model =
    { session : Session.Data
    , scenarios : Scenarios
    , subscriptionStatus : SubscriptionStatus
    , scenario : Maybe Scenario.Scenario
    }


type SubscriptionStatus
    = Connected
    | NotConnected


type Scenarios
    = Failure
    | Loading
    | Success (List Scenario.ScenarioSeed)


init : Session.Data -> ( Model, Cmd Msg )
init session =
    case Session.getScenarios session of
        Just entries ->
            ( Model session (Success entries) NotConnected Nothing
            , Cmd.none
            )

        Nothing ->
            ( Model session Loading NotConnected Nothing
            , Cmd.batch
                [ Scenario.getScenarios session.backendEndpoint GotScenarios
                ]
            )



-- UPDATE


type Msg
    = CreateScenario
    | GetScenario Api.Scalar.Id
    | GotScenarios (Result (Graphql.Http.Error (List Scenario.ScenarioSeed)) (List Scenario.ScenarioSeed))
    | GotScenario (Result (Graphql.Http.Error Scenario.Scenario) Scenario.Scenario)
    | MakeMove Move
    | NewSubscriptionStatus SubscriptionStatus ()
    | ScenarioCreated (Result (Graphql.Http.Error Id) Id)
    | SentMove (Result (Graphql.Http.Error ()) ())
    | SubscriptionDataReceived Json.Decode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreateScenario ->
            ( model, Scenario.createScenario model.session.backendEndpoint ScenarioCreated )

        GetScenario id ->
            ( model, Scenario.getScenario model.session.backendEndpoint id GotScenario )

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

        GotScenario result ->
            case result of
                Err _ ->
                    ( model
                    , Cmd.none
                    )

                Ok scenario ->
                    ( { model
                        | scenario = Just scenario
                      }
                    , Js.createSubscriptions (subscribeToMoves scenario.id |> Graphql.Document.serializeSubscription)
                    )

        MakeMove move ->
            case model.scenario of
                Just scenario ->
                    ( model
                    , Scenario.makeMove model.session.backendEndpoint scenario.id move SentMove
                    )

                Nothing ->
                    ( model, Cmd.none )

        NewSubscriptionStatus status () ->
            ( { model | subscriptionStatus = status }, Cmd.none )

        ScenarioCreated result ->
            case result of
                Err _ ->
                    ( model
                    , Cmd.none
                    )

                Ok id ->
                    case model.scenarios of
                        Success scenarios ->
                            ( { model | scenarios = Success <| scenarios ++ [ Scenario.ScenarioSeed id ] }, Scenario.getScenario model.session.backendEndpoint id GotScenario )

                        -- This state should not be possible (assuming we aren't able to click the create button unless we are loaded.
                        _ ->
                            ( model
                            , Cmd.none
                            )

        SentMove _ ->
            ( model, Cmd.none )

        SubscriptionDataReceived newData ->
            case model.scenario of
                Just scenario ->
                    case Json.Decode.decodeValue (subscribeToMoves scenario.id |> Graphql.Document.decoder) newData of
                        Ok s ->
                            ( { model | scenario = Just s }, Cmd.none )

                        Err error ->
                            ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Skeleton.Details Msg
view model =
    { title = "Learn"
    , header = []
    , warning = Skeleton.NoProblems
    , attrs = [ class "container mx-auto px-4" ]
    , children =
        [ lazy viewScenarios model.scenarios
        , Chess.Game.view (Result.withDefault Chess.Game.blankBoard <| Chess.Game.fromFen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
        , lazy viewLearn model.scenario
        ]
    }


viewConnection : SubscriptionStatus -> Html Msg
viewConnection status =
    case status of
        Connected ->
            div [] [ text "Connected :tada:!" ]

        NotConnected ->
            div [] [ text "It seems we can't connect :( maybe try refreshing." ]


viewScenarios : Scenarios -> Html Msg
viewScenarios scenarios =
    div [ classList [ ( "scenarios", True ), ( "p-6 max-w-sm mx-auto bg-white rounded-xl shadow-md flex items-center space-x-4", True ) ] ]
        [ case scenarios of
            Failure ->
                div [] []

            --div Problem.styles (Problem.offline "scenarios.json")
            Loading ->
                text ""

            Success [] ->
                div [ class "flex-shrink-0 text-xl font-medium text-purple-600" ]
                    [ button [ onClick CreateScenario ] [ text "Create Scenario" ]
                    , text "You don't seem to have any scenarios."
                    ]

            Success ss ->
                div []
                    ([ button [ onClick CreateScenario ] [ text "Create Scenario" ]
                     ]
                        ++ List.map viewSelectScenario ss
                    )
        ]


viewSelectScenario : Scenario.ScenarioSeed -> Html Msg
viewSelectScenario { id } =
    let
        (Api.Scalar.Id raw) =
            id
    in
    div []
        [ button [ onClick (GetScenario id) ] [ text raw ]
        ]



-- VIEW LEARN


viewLearn : Maybe Scenario.Scenario -> Html Msg
viewLearn scenario =
    div [ class "p-6 max-w-sm mx-auto bg-white rounded-xl shadow-md flex items-center space-x-4" ]
        [ case scenario of
            Just s ->
                viewScenario s

            Nothing ->
                div [] []
        ]



-- VIEW SCENARIO


viewScenario : Scenario.Scenario -> Html Msg
viewScenario scenario =
    div [ class "container flex flex-col mx-auto px-4" ]
        [ h3 [] [ text "Current state" ]
        , div [] (List.map viewMakeMove scenario.availableMoves)
        , p [ class "current-state" ] [ text scenario.currentState ]
        ]


viewMakeMove : Move -> Html Msg
viewMakeMove move =
    div []
        [ button [ onClick (MakeMove move), class <| backgroundColor move.color ] [ text <| "Move " ++ move.squareFrom ++ move.squareTo ]
        ]


backgroundColor : String -> String
backgroundColor color =
    if color == "b" then
        "bg-blue-500"

    else
        "bg-red-500"



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Js.gotSubscriptionData SubscriptionDataReceived
        , Js.socketStatusConnected (NewSubscriptionStatus Connected)
        ]

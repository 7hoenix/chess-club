module Page.Learn exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Api.Scalar exposing (Id)
import Api.Subscription as Subscription
import Graphql.Document
import Graphql.Http
import Graphql.Operation exposing (RootSubscription)
import Graphql.SelectionSet exposing (SelectionSet)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html.Lazy exposing (..)
import Js
import Json.Decode
import Page.Learn.Scenario as Scenario exposing (Move, moveSelection, scenarioSelection)
import Page.Problem as Problem
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
    | Success (List Scenario.Scenario)


init : Session.Data -> ( Model, Cmd Msg )
init session =
    case Session.getScenarios session of
        Just entries ->
            ( Model session (Success entries) NotConnected Nothing
            , Js.createSubscriptions (subscriptionDocument |> Graphql.Document.serializeSubscription)
            )

        Nothing ->
            ( Model session Loading NotConnected Nothing
            , Cmd.batch
                [ Js.createSubscriptions (subscriptionDocument |> Graphql.Document.serializeSubscription)
                , Scenario.getScenario session.backendEndpoint "1" GotScenario
                ]
            )


subscriptionDocument : SelectionSet Scenario.Scenario RootSubscription
subscriptionDocument =
    Subscription.moveMade { scenarioId = Api.Scalar.Id "1" } scenarioSelection



-- UPDATE


type Msg
    = GotScenario (Result (Graphql.Http.Error Scenario.Scenario) Scenario.Scenario)
    | MakeMove Move
    | NewSubscriptionStatus SubscriptionStatus ()
    | SentMove (Result (Graphql.Http.Error ()) ())
    | SubscriptionDataReceived Json.Decode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotScenario result ->
            case result of
                Err _ ->
                    ( { model | scenarios = Failure }
                    , Cmd.none
                    )

                Ok scenario ->
                    ( { model
                        | scenarios = Success [ scenario ]
                        , scenario = Just scenario
                        , session = Session.addScenarios [ scenario ] model.session
                      }
                    , Cmd.none
                    )

        MakeMove move ->
            ( model
            , Scenario.makeMove model.session.backendEndpoint move SentMove
            )

        NewSubscriptionStatus status () ->
            ( { model | subscriptionStatus = status }, Cmd.none )

        SentMove _ ->
            ( model, Cmd.none )

        SubscriptionDataReceived newData ->
            case Json.Decode.decodeValue (subscriptionDocument |> Graphql.Document.decoder) newData of
                Ok scenario ->
                    ( { model | scenario = Just scenario }, Cmd.none )

                Err error ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Skeleton.Details Msg
view model =
    { title = "Learn"
    , header = []
    , warning = Skeleton.NoProblems
    , attrs = [ class "container mx-auto px-4" ]
    , children =
        [ viewConnection model.subscriptionStatus

        --, lazy viewScenario model.scenario
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



-- VIEW LEARN


viewLearn : Maybe Scenario.Scenario -> Html Msg
viewLearn scenario =
    div [ class "p-6 max-w-sm mx-auto bg-white rounded-xl shadow-md flex items-center space-x-4" ]
        [ case scenario of
            Just s ->
                viewScenario s

            Nothing ->
                div [ class "flex-shrink-0 text-xl font-medium text-purple-600" ]
                    [ text "You don't seem to have any scenarios." ]

        --Failure ->
        --    div Problem.styles (Problem.offline "scenarios.json")
        --
        --Loading ->
        --    text ""
        --
        ---- TODO handle multiple scenarios.
        --Success (scenario :: _) ->
        --    div []
        --        [ viewScenario scenario
        --        ]
        --
        --Success _ ->
        --    div [ class "flex-shrink-0 text-xl font-medium text-purple-600" ]
        --        [ text "You don't seem to have any scenarios." ]
        ]



-- VIEW SCENARIO


viewScenario : Scenario.Scenario -> Html Msg
viewScenario scenario =
    div [ class "container flex flex-col mx-auto px-4" ]
        [ h3 [] [ text "Current state" ]
        , div [] (List.map viewMakeMove scenario.availableMoves)
        , p [ class "current-state" ] [ text scenario.currentState ]
        ]



--viewRecentMove : Maybe Scenario.Scenario -> Html Msg
--viewRecentMove scenario =
--    div [ class "container flex flex-col mx-auto px-4" ]
--        [ button [ onClick (MakeMove "a1" "a2"), class "bg-green-500" ] [ text "Move a1a2" ]
--        , button [ onClick (MakeMove "a2" "a1"), class "bg-red-500" ] [ text "Move a2a1" ]
--        , div [ class "container" ]
--            [ case move of
--                Nothing ->
--                    text "No recent move here"
--
--                Just m ->
--                    text <| m.squareFrom ++ m.squareTo
--            ]
--        ]


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

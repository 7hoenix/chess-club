module Page.Learn exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Api.Object exposing (Move)
import Api.Object.Move
import Api.Scalar exposing (Id)
import Api.Subscription as Subscription
import Graphql.Document
import Graphql.Http
import Graphql.Operation exposing (RootSubscription)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Lazy exposing (..)
import Js
import Json.Decode
import Page.Learn.Scenario as Scenario
import Page.Problem as Problem
import Session
import Skeleton



-- MODEL


type alias Model =
    { session : Session.Data
    , scenarios : Scenarios
    , subscriptionStatus : SubsscriptionStatus
    }


type SubsscriptionStatus
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
            ( Model session (Success entries) NotConnected
            , Js.createSubscriptions (subscriptionDocument |> Graphql.Document.serializeSubscription)
            )

        Nothing ->
            ( Model session Loading NotConnected
            , Cmd.batch
                [ Js.createSubscriptions (subscriptionDocument |> Graphql.Document.serializeSubscription)
                , Scenario.getScenarios session.backendEndpoint GotScenarios
                ]
            )


subscriptionDocument : SelectionSet Move RootSubscription
subscriptionDocument =
    Subscription.moveMade { scenarioId = Api.Scalar.Id "1" } moveSelection


type alias Move =
    { squareFrom : String
    , squareTo : String
    }


moveSelection : SelectionSet Move Api.Object.Move
moveSelection =
    SelectionSet.succeed Move
        |> with Api.Object.Move.squareFrom
        |> with Api.Object.Move.squareTo



-- UPDATE


type Msg
    = GotScenarios (Result (Graphql.Http.Error (List Scenario.Scenario)) (List Scenario.Scenario))
    | SubscriptionDataReceived Json.Decode.Value
    | NewSubscriptionStatus SubsscriptionStatus ()


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

        SubscriptionDataReceived newData ->
            case Json.Decode.decodeValue (subscriptionDocument |> Graphql.Document.decoder) newData of
                Ok newMove ->
                    ( model, Cmd.none )

                Err error ->
                    ( model, Cmd.none )

        NewSubscriptionStatus status () ->
            ( { model | subscriptionStatus = status }, Cmd.none )



-- VIEW


view : Model -> Skeleton.Details Msg
view model =
    { title = "Learn"
    , header = []
    , warning = Skeleton.NoProblems
    , attrs = [ class "container mx-auto px-4" ]
    , children =
        [ viewConnection model.subscriptionStatus
        , lazy viewLearn model.scenarios
        ]
    }


viewConnection : SubsscriptionStatus -> Html Msg
viewConnection status =
    case status of
        Connected ->
            div [] [ text "Connected :tada:!" ]

        NotConnected ->
            div [] [ text "It seems we can't connect :( maybe try refreshing." ]



-- VIEW LEARN


viewLearn : Scenarios -> Html Msg
viewLearn scenarios =
    div [ class "p-6 max-w-sm mx-auto bg-white rounded-xl shadow-md flex items-center space-x-4" ]
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
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Js.gotSubscriptionData SubscriptionDataReceived
        , Js.socketStatusConnected (NewSubscriptionStatus Connected)
        ]

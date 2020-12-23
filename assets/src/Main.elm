module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (text)
import Page.Learn as Learn
import Page.Problem as Problem
import Session
import Skeleton
import Url
import Url.Parser as Parser exposing ((</>), Parser, custom, fragment, map, oneOf, s, top)



-- MAIN


main =
    Browser.application
        { init =
            \flags url navKey ->
                init flags url navKey
                    |> Tuple.mapSecond perform
        , view = view
        , update =
            \msg model ->
                update msg model
                    |> Tuple.mapSecond perform
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    , backendEndpoint : String
    }


type Page
    = NotFound Session.Data
    | Learn Learn.Model


type Effect
    = NoEffect
    | CmdEffect (Cmd Msg)
    | LearnEffect Learn.Effect



-- EFFECTS


perform : Effect -> Cmd Msg
perform effect =
    case effect of
        NoEffect ->
            Cmd.none

        CmdEffect cmd ->
            cmd

        LearnEffect learn ->
            Cmd.map LearnMsg <| Learn.perform learn



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model.page of
        NotFound _ ->
            Skeleton.view never
                { title = "Not Found"
                , header = []
                , warning = Skeleton.NoProblems
                , attrs = Problem.styles
                , children = Problem.notFound
                }

        Learn learn ->
            Skeleton.view LearnMsg (Learn.view learn)



-- INIT


type alias Flags =
    { backendEndpoint : String }


init : Flags -> Url.Url -> Nav.Key -> ( Model, Effect )
init { backendEndpoint } url key =
    stepUrl url
        { key = key
        , page = NotFound <| Session.empty backendEndpoint
        , backendEndpoint = backendEndpoint
        }



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | LearnMsg Learn.Msg


update : Msg -> Model -> ( Model, Effect )
update message model =
    case message of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , CmdEffect <| Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , CmdEffect <| Nav.load href
                    )

        UrlChanged url ->
            stepUrl url model

        LearnMsg msg ->
            case model.page of
                Learn learn ->
                    stepLearn model (Learn.update msg learn |> Tuple.mapSecond LearnEffect)

                _ ->
                    ( model, NoEffect )


stepLearn : Model -> ( Learn.Model, Effect ) -> ( Model, Effect )
stepLearn model ( learn, effect ) =
    ( { model | page = Learn learn }
    , effect
    )



-- EXIT


exit : Model -> Session.Data
exit model =
    case model.page of
        NotFound session ->
            session

        Learn m ->
            m.session



-- ROUTER


stepUrl : Url.Url -> Model -> ( Model, Effect )
stepUrl url model =
    let
        session =
            exit model

        parser =
            oneOf
                [ route top
                    (stepLearn model (Learn.init session |> Tuple.mapSecond LearnEffect))
                ]
    in
    case Parser.parse parser url of
        Just answer ->
            answer

        Nothing ->
            ( { model | page = NotFound session }
            , NoEffect
            )


route : Parser a b -> a -> Parser (b -> c) c
route parser handler =
    Parser.map handler parser

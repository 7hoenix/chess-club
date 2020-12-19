module Page.Learn exposing
    ( Model
    , Msg
    , init
    , update
    , view
    )

import Html exposing (..)
import Html.Attributes exposing (autofocus, class, href, placeholder, style, value)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Html.Lazy exposing (..)
import Http
import Json.Decode as Decode
import Page.Learn.Lesson as Lesson
import Page.Problem as Problem
import Session
import Skeleton
import Url.Builder as Url



-- MODEL


type alias Model =
    { session : Session.Data
    , lessons : Lessons
    }


type Lessons
    = Failure
    | Loading
    | Success (List Lesson.Lesson)


init : Session.Data -> ( Model, Cmd Msg )
init session =
    case Session.getLessons session of
        Just entries ->
            ( Model session (Success entries)
            , Cmd.none
            )

        Nothing ->
            ( Model session (Success [])
              --( Model session Loading
            , Cmd.none
              -- TODO
              --, Http.send GotLessons <|
              --    Http.get "/lessons.json" (Decode.list Lesson.decoder)
            )



-- UPDATE


type Msg
    = GotLessons (Result Http.Error (List Lesson.Lesson))


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        GotLessons result ->
            case result of
                Err _ ->
                    ( { model | lessons = Failure }
                    , Cmd.none
                    )

                Ok lessons ->
                    ( { model
                        | lessons = Success lessons
                        , session = Session.addLessons lessons model.session
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
        [ lazy viewLearn model.lessons
        ]
    }



-- VIEW LEARN


viewLearn : Lessons -> Html Msg
viewLearn lessons =
    div [ class "p-6 max-w-sm mx-auto bg-white rounded-xl shadow-md flex items-center space-x-4" ]
        [ case lessons of
            Failure ->
                div Problem.styles (Problem.offline "lessons.json")

            Loading ->
                text ""

            -- TODO
            -- TODO handle multiple lessons.
            Success (lesson :: _) ->
                div []
                    [ viewLesson lesson
                    ]

            Success _ ->
                div [ class "flex-shrink-0 text-xl font-medium text-black" ]
                    [ text "You don't seem to have any lessons." ]
        ]



-- VIEW LESSON


viewLesson : Lesson.Lesson -> Html msg
viewLesson lesson =
    div []
        [ h3 [] [ text "Lesson Title" ]
        , p [] [ text lesson.title ]
        ]

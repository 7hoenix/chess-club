module Page.LearnTest exposing (all, start)

import Api.Scalar exposing (Id(..))
import Backend exposing (Backend)
import Page.Learn as Learn
import Page.Learn.Scenario as Scenario
import ProgramTest exposing (ProgramTest, clickButton, expectViewHas, fillIn, update)
import Skeleton
import Test exposing (..)
import Test.Html.Selector exposing (text)


initialStartingState =
    "some-fen-string"


backend : Backend
backend =
    Backend.api "http://foo.bar" "some-auth-token"


loadedData =
    { scenarios = Just [ Scenario.ScenarioSeed (Id "1") ]
    }


start : ProgramTest Learn.Model Learn.Msg (Cmd Learn.Msg)
start =
    ProgramTest.createDocument
        { init = \_ -> Learn.init backend loadedData
        , view = \model -> Skeleton.view backend (\msg -> msg) (Learn.view model)
        , update = Learn.update backend
        }
        |> ProgramTest.start ()


all : Test
all =
    describe "Learn page"
        [ test "shows trivial" <|
            \() ->
                start
                    |> expectViewHas [ text "1" ]
        ]

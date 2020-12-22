module Page.LearnTest exposing (all, start)

import Api.Scalar exposing (Id(..))
import Page.Learn as Learn
import Page.Learn.Scenario as Scenario
import ProgramTest exposing (ProgramTest, clickButton, expectViewHas, fillIn, update)
import Skeleton
import Test exposing (..)
import Test.Html.Selector exposing (text)


initialStartingState =
    "some-fen-string"


loadedData =
    { scenarios = Just [ Scenario.Scenario initialStartingState (Id "1") ]
    , backendEndpoint = "http://foo.bar"
    }


start : ProgramTest Learn.Model Learn.Msg (Cmd Learn.Msg)
start =
    ProgramTest.createDocument
        { init = \_ -> Learn.init loadedData
        , view = \model -> Skeleton.view (\msg -> msg) (Learn.view model)
        , update = Learn.update
        }
        |> ProgramTest.start ()


all : Test
all =
    describe "Learn page"
        [ test "shows trivial" <|
            \() ->
                start
                    |> expectViewHas [ text initialStartingState ]
        ]

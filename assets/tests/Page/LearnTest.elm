module Page.LearnTest exposing (all, emptyData, start)

import Page.Learn as Learn
import ProgramTest exposing (ProgramTest, clickButton, expectViewHas, fillIn, update)
import Skeleton
import Test exposing (..)
import Test.Html.Selector exposing (text)


emptyData =
    { lessons = Nothing
    }


start : ProgramTest Learn.Model Learn.Msg (Cmd Learn.Msg)
start =
    ProgramTest.createDocument
        { init = \_ -> Learn.init emptyData
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
                    |> expectViewHas [ text "You don't seem to have any lessons." ]
        ]

module Session exposing
    ( Data
    , addLessons
    , empty
    , getLessons
    )

import Page.Learn.Lesson as Lesson



-- SESSION DATA


type alias Data =
    { lessons : Maybe (List Lesson.Lesson)
    }


empty : Data
empty =
    Data Nothing



-- LESSONS


getLessons : Data -> Maybe (List Lesson.Lesson)
getLessons data =
    data.lessons


addLessons : List Lesson.Lesson -> Data -> Data
addLessons lessons data =
    { data | lessons = Just lessons }

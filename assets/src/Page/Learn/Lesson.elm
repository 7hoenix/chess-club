module Page.Learn.Lesson exposing
  ( Lesson
  , decoder
  )


import Json.Decode as D



-- LESSON


type alias Lesson =
  { title : String
  }


-- DECODER


decoder : D.Decoder Lesson
decoder =
  D.map Lesson
    (D.field "name" D.string)

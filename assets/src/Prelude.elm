module Prelude exposing (Segment(..), maybe)


type Segment
    = Text String
    | Link String String


maybe : b -> (a -> b) -> Maybe a -> b
maybe default f x =
    case x of
        Nothing ->
            default

        Just a ->
            f a

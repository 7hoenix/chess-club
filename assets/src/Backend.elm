module Backend exposing
    ( AuthToken
    , Backend
    , api
    , sendAuthorizedMutation
    , sendAuthorizedQuery
    )

import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet)


type alias Backend =
    { endpoint : String
    , authToken : AuthToken
    }


api : String -> String -> Backend
api endpoint authToken =
    Backend endpoint (AuthToken authToken)



-- AUTHORIZATION


type AuthToken
    = AuthToken String


getAuthToken : AuthToken -> String
getAuthToken (AuthToken raw) =
    raw



-- AUTHORIZED GRAPHQL


sendAuthorizedQuery : Backend -> SelectionSet decodesTo RootQuery -> (Result (Graphql.Http.Error decodesTo) decodesTo -> msg) -> Cmd msg
sendAuthorizedQuery backend sender msg =
    sender
        |> Graphql.Http.queryRequest (backend.endpoint ++ "/api/graphql")
        |> Graphql.Http.withHeader "authorization" ("Bearer " ++ getAuthToken backend.authToken)
        |> Graphql.Http.send msg


sendAuthorizedMutation : Backend -> SelectionSet decodesTo RootMutation -> (Result (Graphql.Http.Error decodesTo) decodesTo -> msg) -> Cmd msg
sendAuthorizedMutation backend sender msg =
    sender
        |> Graphql.Http.mutationRequest (backend.endpoint ++ "/api/graphql")
        |> Graphql.Http.withHeader "authorization" ("Bearer " ++ getAuthToken backend.authToken)
        |> Graphql.Http.send msg

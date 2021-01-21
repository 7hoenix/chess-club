module Backend exposing (AuthToken, Backend, api, getAuthToken)


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

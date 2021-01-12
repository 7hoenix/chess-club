ExUnit.start(exclude: [:skip])

Ecto.Adapters.SQL.Sandbox.mode(ChessClub.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:ex_machina)

Mox.Server.start_link([])

Mox.defmock(HTTPoison.BaseMock, for: HTTPoison.Base)

Application.put_env(:chess_club, :http_client, HTTPoison.BaseMock)
# Replace this with the serverless endpoints
Application.put_env(:chess_club, :chess_api_url, "http://chess_api.com")

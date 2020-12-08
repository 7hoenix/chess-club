defmodule ChessClub.Repo do
  use Ecto.Repo,
    otp_app: :chess_club,
    adapter: Ecto.Adapters.Postgres
end

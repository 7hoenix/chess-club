defmodule ChessClub.UserManager.Pipeline do
  @moduledoc "Plug Pipeline for User Authentication"
  use Guardian.Plug.Pipeline,
    otp_app: :chess_club,
    error_handler: ChessClub.UserManager.ErrorHandler,
    module: ChessClub.UserManager.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end

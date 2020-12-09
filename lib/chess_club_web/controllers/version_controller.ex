defmodule ChessClubWeb.VersionController do
  use ChessClubWeb, :controller

  def index(conn, _params) do
    resp =
      case :application.get_key(:chess_club, :vsn) do
        {:ok, vsn} -> vsn
        _ -> "version not found :("
      end

    send_resp(conn, 200, resp)
  end
end

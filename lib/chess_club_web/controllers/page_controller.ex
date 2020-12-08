defmodule ChessClubWeb.PageController do
  use ChessClubWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

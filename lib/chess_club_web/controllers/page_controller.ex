defmodule ChessClubWeb.PageController do
  use ChessClubWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def app(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "app.html", current_user: user)
  end
end

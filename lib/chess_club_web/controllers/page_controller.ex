defmodule ChessClubWeb.PageController do
  use ChessClubWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout("index.html")
    |> render("index.html")
  end

  def app(conn, _) do
    user = Guardian.Plug.current_resource(conn)

    conn
    |> put_layout("app.html")
    |> render("app.html", current_user: user)
  end
end

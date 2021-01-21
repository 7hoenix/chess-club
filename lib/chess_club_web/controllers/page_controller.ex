defmodule ChessClubWeb.PageController do
  use ChessClubWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout("index.html")
    |> render("index.html")
  end

  def app(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    {:ok, token, _claims} = ChessClub.UserManager.Guardian.encode_and_sign(user)

    conn
    |> put_layout("app.html")
    |> render("app.html", current_user: user, auth_token: token)
  end
end

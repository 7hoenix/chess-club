defmodule ChessClubWeb.UserController do
  use ChessClubWeb, :controller

  alias ChessClub.UserManager
  alias ChessClub.UserManager.User
  alias UserManager.Guardian

  def new(conn, _) do
    changeset = UserManager.change_user(%User{})
    maybe_user = Guardian.Plug.current_resource(conn)

    if maybe_user do
      redirect(conn, to: "/app")
    else
      conn
      |> put_layout("index.html")
      |> render("new.html", %{changeset: changeset, action: Routes.user_path(conn, :create)})
    end
  end

  def create(conn, %{"user" => user_params}) do
    # FOLLOWUP: what should happen if user account already exists or if user is signed in?
    with {:ok, %User{} = _user} <- UserManager.create_user(user_params) do
      conn
      |> put_flash(:info, "User account created successfully.")
      |> redirect(to: Routes.session_path(conn, :login))
    end
  end
end

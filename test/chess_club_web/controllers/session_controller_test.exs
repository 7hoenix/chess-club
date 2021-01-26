defmodule ChessClubWeb.SessionControllerTest do
  use ChessClubWeb.ConnCase

  alias ChessClub.UserManager
  alias ChessClub.UserManager.User

  test "GET /login", %{conn: conn} do
    conn = get(conn, "/login")
    assert html_response(conn, 200) =~ "Sign in to your account"
  end

  describe "create a session" do
    test "redirects to app if authenticated", %{conn: conn} do
      {:ok, %User{}} =
        UserManager.create_user(%{
          password: "some password",
          password_confirmation: "some password",
          username: "some username"
        })

      login_attrs = %{password: "some password", username: "some username"}

      conn = post(conn, Routes.session_path(conn, :login), user: login_attrs)

      assert redirected_to(conn) == Routes.page_path(conn, :app)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      login_attrs = %{password: "some password", username: "not a user"}

      conn = post(conn, Routes.session_path(conn, :login), user: login_attrs)

      assert html_response(conn, 200) =~ "Sign in to your account"
    end
  end
end

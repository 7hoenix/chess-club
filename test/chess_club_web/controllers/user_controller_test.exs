defmodule ChessClubWeb.UserControllerTest do
  use ChessClubWeb.ConnCase

  test "GET /acccount", %{conn: conn} do
    conn = get(conn, "/account")
    assert html_response(conn, 200) =~ "Create account"
  end

  describe "create user" do
    test "redirects to login page if valid", %{conn: conn} do
      create_attrs = %{
        username: "joyce",
        password: "password1",
        password_confirmation: "password1"
      }

      conn = post(conn, Routes.user_path(conn, :create), user: create_attrs)

      assert redirected_to(conn) == Routes.session_path(conn, :login)
    end
  end
end

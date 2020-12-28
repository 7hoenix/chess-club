defmodule ChessClubWeb.PageControllerTest do
  use ChessClubWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Online Chess Club"
  end
end

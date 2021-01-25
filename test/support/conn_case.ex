defmodule ChessClubWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ChessClubWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias ChessClub.Factory
  alias ChessClub.UserManager.Guardian
  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import ChessClubWeb.ConnCase

      alias ChessClub.Factory
      # credo:disable-for-next-line
      alias ChessClubWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint ChessClubWeb.Endpoint
    end
  end

  setup tags do
    :ok = Sandbox.checkout(ChessClub.Repo)

    unless tags[:async] do
      Sandbox.mode(ChessClub.Repo, {:shared, self()})
    end

    user = Factory.insert(:user)
    {:ok, auth_token, _claims} = Guardian.encode_and_sign(user)

    authorized_conn =
      Plug.Conn.put_req_header(
        Phoenix.ConnTest.build_conn(),
        "authorization",
        "Bearer #{auth_token}"
      )

    {:ok, conn: Phoenix.ConnTest.build_conn(), authorized_conn: authorized_conn}
  end
end

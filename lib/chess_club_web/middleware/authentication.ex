defmodule ChessClubWeb.Middleware.Authentication do
  @moduledoc "GraphQL Authentication Middleware"
  @behaviour Absinthe.Middleware

  def call(resolution, _config) do
    case resolution.context do
      %{current_user: _} -> resolution
      _ -> Absinthe.Resolution.put_result(resolution, {:error, "unauthenticated"})
    end
  end
end

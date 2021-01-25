defmodule ChessClub.UserManager.Context do
  @moduledoc "Authentication middleware"
  @behaviour Plug

  import Plug.Conn

  alias ChessClub.UserManager.Guardian

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(token) do
      %{current_user: current_user}
    else
      _ ->
        %{}
    end
  end

  defp authorize(token) do
    Guardian.decode_and_verify(token, %{"typ" => "access"})
  end
end

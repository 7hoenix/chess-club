defmodule ChessClub.UserManager.Context do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(token) do
      %{current_user: current_user}
    else
      _ ->
        %{}
    end
  end

  defp authorize(token) do
    token
    |> ChessClub.UserManager.Guardian.decode_and_verify(%{"typ" => "access"})
  end
end

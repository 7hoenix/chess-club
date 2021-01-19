defmodule ChessClub.Chess.Game do
  use GenServer

  alias ChessClub.Chess.Move
  @expected_fields ~w(
                      moves current_state
                    )

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  ## CLIENT

  @doc """
  Will call out to the underlying Python server over Erlport to get available chess moves.
  """
  def available_moves(server, fen, moves_made) do
    GenServer.call(server, {:available_moves, %{fen: fen, moves_made: moves_made}})
  end

  ## SERVER

  @impl true
  def init(:ok) do
    {:ok, py} = :python.start([{:python_path, './api'}, {:python, 'python3'}])
    {:ok, %{chess_server: py}}
  end

  @impl true
  def handle_call({:available_moves, %{fen: fen, moves_made: moves_made}}, _from, %{
        chess_server: server
      }) do
    {:ok, request_body} = %{board: fen, moves_made: moves_made} |> Poison.encode()
    body = :python.call(server, :app, :route_moves_erlport, [request_body])

    %{moves: moves, current_state: current_state} =
      body
      |> extract_response()

    {Enum.map(moves, &to_move/1), current_state}

    {:reply, {Enum.map(moves, &to_move/1), current_state}, %{chess_server: server}}
  end

  defp extract_response(body) do
    body
    |> Poison.decode!()
    |> Map.take(@expected_fields)
    |> Enum.reduce(%{}, fn {key, val}, acc -> Map.put(acc, String.to_atom(key), val) end)
  end

  defp to_move(%{
         "from" => square_from,
         "to" => square_to,
         "player" => color,
         "command" => move_command,
         "fenAfterMove" => fen_after_move
       }) do
    c =
      case color do
        "WHITE" -> "w"
        "BLACK" -> "b"
      end

    %Move{
      square_from: square_from,
      square_to: square_to,
      color: c,
      move_command: move_command,
      fen_after_move: fen_after_move
    }
  end
end

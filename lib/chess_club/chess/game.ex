defmodule ChessClub.Chess.Game do
  alias ChessClub.Chess.Move
  @expected_fields ~w(
                      moves current_state
                    )

  def available_moves(fen, moves_made) do
    {:ok, request_body} = %{board: fen, moves_made: moves_made} |> Poison.encode()
    {:ok, py} = :python.start([{:python_path, './api'}, {:python, 'python3'}])
    body = :python.call(py, :app, :route_moves_erlport, [request_body])
    :python.stop(py)

    %{moves: moves, current_state: current_state} =
      body
      |> extract_response()

    {Enum.map(moves, &to_move/1), current_state}
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

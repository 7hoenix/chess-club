defmodule ChessClub.Chess.Game do
  alias ChessClub.Chess.Move
  @expected_fields ~w(
                      moves
                    )

  def available_moves(fen) do
    {:ok, request_body} = %{board: fen} |> Poison.encode()
    {:ok, py} = :python.start([{:python_path, './api'}, {:python, 'python3'}])
    body = :python.call(py, :app, :route_moves_erlport, [request_body])
    :python.stop(py)

    body
    |> extract_response()
    |> List.first()
    |> elem(1)
    |> Enum.map(&to_move/1)
  end

  defp extract_response(body) do
    body
    |> Poison.decode!()
    |> Map.take(@expected_fields)
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp to_move(%{
         "from" => square_from,
         "to" => square_to,
         "player" => color,
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
      fen_after_move: fen_after_move
    }
  end
end

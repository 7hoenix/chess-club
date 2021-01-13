defmodule ChessClub.Chess.Game do
  use HTTPoison.Base
  alias ChessClub.Chess.Move
  @expected_fields ~w(
                      moves
                    )
  @headers [{"Content-Type", "application/json"}]

  def available_moves(fen) do
    {:ok, request_body} = %{board: fen} |> Poison.encode()
    moves_url = chess_api_url() <> "/moves"

    {:ok, %{body: body}} = http_client().post(moves_url, request_body, @headers)

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

  defp http_client do
    Application.get_env(:chess_club, :http_client)
  end

  defp chess_api_url do
    Application.get_env(:chess_club, :chess_api_url)
  end
end

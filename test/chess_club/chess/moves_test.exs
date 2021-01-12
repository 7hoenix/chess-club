defmodule ChessClub.MovesTest do
  use ExUnit.Case

  import Mox

  alias ChessClub.Chess.Move
  alias ChessClub.Chess.Game

  @fen "7k/8/7K/8/7P/8/8/8 b - - 0 77"

  setup :verify_on_exit!

  describe "available_moves" do
    test "sends an HTTP request to the backing service and then maps the result" do
      {:ok, raw} =
        %{
          moves: [
            %{
              from: "h8",
              to: "g8",
              player: "BLACK",
              fenAfterMove: "6k1/8/7K/8/7P/8/8/8 w - - 1 78"
            },
            %{
              from: "h6",
              to: "g6",
              player: "WHITE",
              fenAfterMove: "7k/8/6K1/8/7P/8/8/8 b - - 2 78"
            },
            %{
              from: "h6",
              to: "h5",
              player: "WHITE",
              fenAfterMove: "7k/8/8/7K/7P/8/8/8 b - - 2 78"
            },
            %{
              from: "h6",
              to: "g5",
              player: "WHITE",
              fenAfterMove: "7k/8/8/6K1/7P/8/8/8 b - - 2 78"
            },
            %{
              from: "h4",
              to: "h5",
              player: "WHITE",
              fenAfterMove: "7k/8/7K/7P/8/8/8/8 b - - 0 78"
            }
          ]
        }
        |> Poison.encode()

      {:ok, body} = %{board: @fen} |> Poison.encode()
      headers = [{"Content-Type", "application/json"}]
      url = Application.get_env(:chess_club, :chess_api_url)
      expected_url = url <> "/moves"

      expect(HTTPoison.BaseMock, :post, fn ^expected_url, ^body, ^headers ->
        {:ok, %{body: raw}}
      end)

      moves = Game.available_moves(@fen)

      expected_moves = [
        %Move{from: "h8", to: "g8", color: "b", fen_after_move: "6k1/8/7K/8/7P/8/8/8 w - - 1 78"},
        %Move{from: "h6", to: "g6", color: "w", fen_after_move: "7k/8/6K1/8/7P/8/8/8 b - - 2 78"},
        %Move{from: "h6", to: "h5", color: "w", fen_after_move: "7k/8/8/7K/7P/8/8/8 b - - 2 78"},
        %Move{from: "h6", to: "g5", color: "w", fen_after_move: "7k/8/8/6K1/7P/8/8/8 b - - 2 78"},
        %Move{from: "h4", to: "h5", color: "w", fen_after_move: "7k/8/7K/7P/8/8/8/8 b - - 0 78"}
      ]

      assert moves == expected_moves
    end
  end
end

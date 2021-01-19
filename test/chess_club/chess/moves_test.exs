defmodule ChessClub.MovesTest do
  use ExUnit.Case, async: true

  alias ChessClub.Chess.Move
  alias ChessClub.Chess.Game

  @fen "7k/8/7K/8/7P/8/8/8 b - - 0 77"

  setup do
    server = start_supervised!(Game)
    %{chess_server: server}
  end

  # NOTE: This currently is hooked up to run through erlport
  # So if its failing randomly, ensure that you are using a
  # python virtualenv and that you have the underlying python chess
  # lib installed.
  describe "available_moves" do
    @tag mustexec: true
    test "returns all available_moves", %{chess_server: server} do
      {moves, _} = Game.available_moves(server, @fen, [])

      expected_moves = [
        %Move{
          square_from: "h8",
          square_to: "g8",
          color: "b",
          move_command: "h8g8",
          fen_after_move: "6k1/8/7K/8/7P/8/8/8 w - - 1 78"
        },
        %Move{
          square_from: "h6",
          square_to: "g6",
          color: "w",
          move_command: "h6g6",
          fen_after_move: "7k/8/6K1/8/7P/8/8/8 b - - 2 78"
        },
        %Move{
          square_from: "h6",
          square_to: "h5",
          color: "w",
          move_command: "h6h5",
          fen_after_move: "7k/8/8/7K/7P/8/8/8 b - - 2 78"
        },
        %Move{
          square_from: "h6",
          square_to: "g5",
          color: "w",
          move_command: "h6g5",
          fen_after_move: "7k/8/8/6K1/7P/8/8/8 b - - 2 78"
        },
        %Move{
          square_from: "h4",
          square_to: "h5",
          color: "w",
          move_command: "h4h5",
          fen_after_move: "7k/8/7K/7P/8/8/8/8 b - - 0 78"
        }
      ]

      assert moves == expected_moves
    end
  end
end

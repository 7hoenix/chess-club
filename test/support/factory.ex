defmodule ChessClub.Factory do
  use ExMachina.Ecto, repo: ChessClub.Repo

  alias ChessClub.Learn.Scenario

  @blank_board "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  def scenario_factory do
    %Scenario{
      starting_state: @blank_board
    }
  end
end

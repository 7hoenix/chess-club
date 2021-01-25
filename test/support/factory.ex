defmodule ChessClub.Factory do
  @moduledoc "Factory for creating data to support testing"
  use ExMachina.Ecto, repo: ChessClub.Repo

  alias ChessClub.Learn.Scenario
  alias ChessClub.Learn.Move
  alias ChessClub.UserManager.User

  @blank_board "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  def scenario_factory do
    %Scenario{
      starting_state: @blank_board
    }
  end

  def move_factory do
    %Move{
      move_command: "a2a3",
      scenario: build(:scenario)
    }
  end

  def user_factory do
    %User{
      username: "joyce",
      password_hashed: "some_hashed_password"
    }
  end
end

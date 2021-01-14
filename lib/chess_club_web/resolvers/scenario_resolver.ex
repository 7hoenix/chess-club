defmodule ChessClubWeb.ScenarioResolver do
  alias ChessClub.Learn.Scenario

  def all(_root, _args, _info) do
    {:ok, ChessClub.all(Scenario) |> ChessClub.Repo.preload(:moves) }
  end

  def make_move(_root, args, _info) do
    changeset = ChessClub.Learn.Move.changeset(%ChessClub.Learn.Move{}, args)
    ChessClub.Repo.insert(changeset)
  end
end
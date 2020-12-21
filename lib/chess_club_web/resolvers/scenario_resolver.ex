defmodule ChessClubWeb.ScenarioResolver do
  alias ChessClub.Learn.Scenario

  def all(_root, _args, _info) do
    {:ok, ChessClub.all(Scenario)}
  end
end

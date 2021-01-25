defmodule ChessClub.Learn.ScenarioTest do
  use ChessClub.DataCase

  alias ChessClub.Learn.Scenario

  describe "all/1" do
    test "returns created scenarios" do
      {:ok, created_scenario} = Repo.insert(%Scenario{starting_state: "111"})

      [scenario] =
        Scenario
        |> ChessClub.all()
        |> Enum.filter(&(&1.id == created_scenario.id))

      assert scenario.starting_state == "111"
    end
  end
end

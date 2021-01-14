defmodule ChessClubWeb.ScenarioTest do
  use ChessClubWeb.ConnCase

  describe "get scenarios" do
    test "returns all scenarios" do
      scenario = Factory.insert(:scenario)

      assert length(ChessClub.all(ChessClub.Learn.Scenario)) == 1

      query = """
      query { scenario_seeds { id, starting_state } }
      """

      response =
        build_conn()
        |> post("/api/graphql", %{query: query})

      assert json_response(response, 200) == %{
               "data" => %{
                 "scenario_seeds" => [
                   %{
                     "id" => "#{scenario.id}",
                     "starting_state" => scenario.starting_state
                   }
                 ]
               }
             }
    end
  end
end

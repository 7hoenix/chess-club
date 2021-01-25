defmodule ChessClubWeb.ScenarioTest do
  use ChessClubWeb.ConnCase

  describe "create scenario" do
    test "creates a new scenario", %{conn: conn} do
      assert ChessClub.Learn.Scenario |> ChessClub.all() |> Enum.empty?()

      mutation = """
      mutation { createScenario { currentState id } }
      """

      response = post(conn, "/api/graphql", %{query: mutation})

      scenario = List.last(ChessClub.all(ChessClub.Learn.Scenario))

      assert json_response(response, 200) == %{
               "data" => %{
                 "createScenario" => %{
                   "id" => "#{scenario.id}",
                   "currentState" => "#{scenario.starting_state}"
                 }
               }
             }
    end
  end

  describe "get scenarios" do
    test "returns all scenarios", %{conn: conn} do
      scenario = Factory.insert(:scenario)

      assert length(ChessClub.all(ChessClub.Learn.Scenario)) == 1

      query = """
      query { scenarios { id } }
      """

      response = post(conn, "/api/graphql", %{query: query})

      assert json_response(response, 200) == %{
               "data" => %{
                 "scenarios" => [
                   %{
                     "id" => "#{scenario.id}"
                   }
                 ]
               }
             }
    end
  end

  describe "get scenario by id" do
    test "returns the correct scenario", %{conn: conn} do
      Factory.insert(:scenario)
      scenario_b = Factory.insert(:scenario)
      Factory.insert(:scenario)

      query = """
      query {
        scenario(scenarioId: #{scenario_b.id}) {
          id
        }
        }
      """

      response = post(conn, "/api/graphql", %{query: query})

      assert json_response(response, 200) == %{
               "data" => %{
                 "scenario" => %{
                   "id" => "#{scenario_b.id}"
                 }
               }
             }
    end

    test "returns available_moves and current_state", %{conn: conn} do
      starting_state = "7k/8/7K/8/7P/8/8/8 b - - 0 77"
      scenario = Factory.insert(:scenario, %{starting_state: starting_state})

      query = """
      query {
        scenario(scenarioId: #{scenario.id}) {
          currentState,
          availableMoves {
            fenAfterMove
            squareFrom
            squareTo
            color
          }
          id
        }
      }
      """

      response = post(conn, "/api/graphql", %{query: query})

      expected_moves = [
        %{
          "squareFrom" => "h8",
          "squareTo" => "g8",
          "color" => "b",
          "fenAfterMove" => "6k1/8/7K/8/7P/8/8/8 w - - 1 78"
        },
        %{
          "squareFrom" => "h6",
          "squareTo" => "g6",
          "color" => "w",
          "fenAfterMove" => "7k/8/6K1/8/7P/8/8/8 b - - 2 78"
        },
        %{
          "squareFrom" => "h6",
          "squareTo" => "h5",
          "color" => "w",
          "fenAfterMove" => "7k/8/8/7K/7P/8/8/8 b - - 2 78"
        },
        %{
          "squareFrom" => "h6",
          "squareTo" => "g5",
          "color" => "w",
          "fenAfterMove" => "7k/8/8/6K1/7P/8/8/8 b - - 2 78"
        },
        %{
          "squareFrom" => "h4",
          "squareTo" => "h5",
          "color" => "w",
          "fenAfterMove" => "7k/8/7K/7P/8/8/8/8 b - - 0 78"
        }
      ]

      assert json_response(response, 200) == %{
               "data" => %{
                 "scenario" => %{
                   "id" => "#{scenario.id}",
                   "availableMoves" => expected_moves,
                   "currentState" => starting_state
                 }
               }
             }
    end

    test "applies moves taken", %{conn: conn} do
      starting_state = "7k/8/7K/8/7P/8/8/8 b - - 0 77"
      scenario = Factory.insert(:scenario, %{starting_state: starting_state})

      h8g8 = %{
        scenario: scenario,
        move_command: "h8g8"
      }

      move = Factory.insert(:move, h8g8)

      query = """
      query {
        scenario(scenarioId: #{move.scenario_id}) {
          currentState,
          availableMoves {
            fenAfterMove
            squareFrom
            squareTo
            moveCommand
            color
          }
          id
        }
      }
      """

      response = post(conn, "/api/graphql", %{query: query})

      expected_current_state = "6k1/8/7K/8/7P/8/8/8 w - - 1 78"

      expected_moves = [
        %{
          "color" => "w",
          "fenAfterMove" => "6k1/8/6K1/8/7P/8/8/8 b - - 2 78",
          "squareFrom" => "h6",
          "squareTo" => "g6",
          "moveCommand" => "h6g6"
        },
        %{
          "color" => "w",
          "fenAfterMove" => "6k1/8/8/7K/7P/8/8/8 b - - 2 78",
          "squareFrom" => "h6",
          "squareTo" => "h5",
          "moveCommand" => "h6h5"
        },
        %{
          "color" => "w",
          "fenAfterMove" => "6k1/8/8/6K1/7P/8/8/8 b - - 2 78",
          "squareFrom" => "h6",
          "squareTo" => "g5",
          "moveCommand" => "h6g5"
        },
        %{
          "color" => "w",
          "fenAfterMove" => "6k1/8/7K/7P/8/8/8/8 b - - 0 78",
          "squareFrom" => "h4",
          "squareTo" => "h5",
          "moveCommand" => "h4h5"
        },
        %{
          "color" => "b",
          "fenAfterMove" => "7k/8/7K/8/7P/8/8/8 w - - 3 79",
          "squareFrom" => "g8",
          "squareTo" => "h8",
          "moveCommand" => "g8h8"
        },
        %{
          "color" => "b",
          "fenAfterMove" => "5k2/8/7K/8/7P/8/8/8 w - - 3 79",
          "squareFrom" => "g8",
          "squareTo" => "f8",
          "moveCommand" => "g8f8"
        },
        %{
          "color" => "b",
          "fenAfterMove" => "8/5k2/7K/8/7P/8/8/8 w - - 3 79",
          "squareFrom" => "g8",
          "squareTo" => "f7",
          "moveCommand" => "g8f7"
        }
      ]

      assert json_response(response, 200) == %{
               "data" => %{
                 "scenario" => %{
                   "id" => "#{move.scenario_id}",
                   "availableMoves" => expected_moves,
                   "currentState" => expected_current_state
                 }
               }
             }
    end
  end

  describe "make_move" do
    test "will make a move on a scenario", %{conn: conn} do
      starting_state = "7k/8/7K/8/7P/8/8/8 b - - 0 77"
      scenario = Factory.insert(:scenario, %{starting_state: starting_state})

      mutation = """
      mutation {
        makeMove(moveCommand: "h8g8", scenarioId: #{scenario.id}) {
          currentState
          id
        }
      }
      """

      response = post(conn, "/api/graphql", %{query: mutation})

      expected_current_state = "6k1/8/7K/8/7P/8/8/8 w - - 1 78"

      assert json_response(response, 200) == %{
               "data" => %{
                 "makeMove" => %{
                   "id" => "#{scenario.id}",
                   "currentState" => expected_current_state
                 }
               }
             }
    end
  end
end

defmodule ChessClubWeb.ScenarioResolver do
  @moduledoc "Scenario Resolver for GraphQL queries"

  alias ChessClub.Chess.Game
  alias ChessClub.Learn.Move
  alias ChessClub.Learn.Scenario
  alias ChessClub.Repo

  @starting_state "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  def all(_root, _args, _info) do
    scenarios_with_state_and_moves =
      Scenario
      |> Repo.all()
      |> Repo.preload(:moves)
      |> Enum.map(&enrich_scenario/1)

    {:ok, scenarios_with_state_and_moves}
  end

  def create(_root, _args, _info) do
    {:ok, scenario} = Repo.insert(%Scenario{starting_state: @starting_state})

    scenario_with_state_and_moves =
      scenario
      |> Repo.preload(:moves)
      |> enrich_scenario()

    {:ok, scenario_with_state_and_moves}
  end

  def get(_root, args, _info) do
    scenario_with_state_and_moves =
      Scenario
      |> Repo.get(args.scenario_id)
      |> ChessClub.Repo.preload(:moves)
      |> enrich_scenario()

    {:ok, scenario_with_state_and_moves}
  end

  def make_move(_root, args, _info) do
    {:ok, _} = %Move{} |> Move.changeset(args) |> Repo.insert()

    scenario_with_state_and_moves =
      Scenario
      |> ChessClub.Repo.get(args.scenario_id)
      |> ChessClub.Repo.preload(:moves)
      |> enrich_scenario()

    {:ok, scenario_with_state_and_moves}
  end

  defp enrich_scenario(scenario) do
    move_commands = Enum.map(scenario.moves, & &1.move_command)

    {available_moves, current_state} =
      Game.available_moves(Game, scenario.starting_state, move_commands)

    %{
      current_state: current_state,
      available_moves: available_moves,
      id: scenario.id
    }
  end
end

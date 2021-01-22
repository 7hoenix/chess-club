defmodule ChessClubWeb.ScenarioResolver do
  alias ChessClub.Learn.Scenario
  alias ChessClub.Chess.Game

  def all(_root, _args, _info) do
    scenarios = ChessClub.all(Scenario) |> ChessClub.Repo.preload(:moves)
    {:ok, Enum.map(scenarios, &resolve_scenario/1)}
  end

  def create(_root, _args, _info) do
    {:ok, scenario} =
      ChessClub.Repo.insert(%Scenario{
        starting_state: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
      })

    {:ok, resolve_scenario(scenario |> ChessClub.Repo.preload(:moves))}
  end

  def get(_root, args, _info) do
    scenario = ChessClub.Repo.get(Scenario, args.scenario_id) |> ChessClub.Repo.preload(:moves)
    {:ok, resolve_scenario(scenario)}
  end

  def make_move(_root, args, _info) do
    changeset = ChessClub.Learn.Move.changeset(%ChessClub.Learn.Move{}, args)
    {:ok, _} = ChessClub.Repo.insert(changeset)
    scenario = ChessClub.Repo.get(Scenario, args.scenario_id) |> ChessClub.Repo.preload(:moves)
    {:ok, resolve_scenario(scenario)}
  end

  defp resolve_scenario(scenario) do
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

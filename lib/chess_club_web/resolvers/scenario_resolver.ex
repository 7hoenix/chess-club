defmodule ChessClubWeb.ScenarioResolver do
  alias ChessClub.Learn.Scenario
  alias ChessClub.Chess.Game

  def all(_root, _args, _info) do
    {:ok, ChessClub.all(Scenario) |> ChessClub.Repo.preload(:moves)}
  end

  def get(_root, args, _info) do
    scenario = ChessClub.Repo.get(Scenario, args.scenario_id) |> ChessClub.Repo.preload(:moves)
    resolve_scenario(scenario)
  end

  def make_move(_root, args, _info) do
    changeset = ChessClub.Learn.Move.changeset(%ChessClub.Learn.Move{}, args)
    {:ok, _} = ChessClub.Repo.insert(changeset)
    scenario = ChessClub.Repo.get(Scenario, args.scenario_id) |> ChessClub.Repo.preload(:moves)
    resolve_scenario(scenario)
  end

  defp resolve_scenario(scenario) do
    move_commands = Enum.map(scenario.moves, & &1.move_command)

    {available_moves, current_state} =
      Game.available_moves(scenario.starting_state, move_commands)

    {:ok,
     %{
       current_state: current_state,
       available_moves: available_moves,
       id: scenario.id
     }}
  end
end

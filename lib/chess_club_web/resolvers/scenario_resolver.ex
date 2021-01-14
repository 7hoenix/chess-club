defmodule ChessClubWeb.ScenarioResolver do
  alias ChessClub.Learn.Scenario
  alias ChessClub.Chess.Game

  def all(_root, _args, _info) do
    {:ok, ChessClub.all(Scenario) |> ChessClub.Repo.preload(:moves)}
  end

  def get(_root, args, _info) do
    scenario = ChessClub.Repo.get(Scenario, args.scenario_id) |> ChessClub.Repo.preload(:moves)

    case List.last(scenario.moves) do
      nil ->
        available_moves = Game.available_moves(scenario.starting_state)

        {:ok,
         %{
           current_state: scenario.starting_state,
           available_moves: available_moves,
           id: args.scenario_id
         }}

      move ->
        available_moves = Game.available_moves(move.fen_after_move)

        {:ok,
         %{
           current_state: move.fen_after_move,
           available_moves: available_moves,
           id: args.scenario_id
         }}
    end
  end

  def make_move(_root, args, _info) do
    changeset = ChessClub.Learn.Move.changeset(%ChessClub.Learn.Move{}, args)
    {:ok, move} = ChessClub.Repo.insert(changeset)
    # TODO: Consider extracting this state into an enrichment service.
    available_moves = Game.available_moves(move.fen_after_move)

    {:ok,
     %{
       current_state: move.fen_after_move,
       available_moves: available_moves,
       id: args.scenario_id
     }}
  end
end

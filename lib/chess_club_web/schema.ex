defmodule ChessClubWeb.Schema do
  use Absinthe.Schema

  alias ChessClubWeb.ScenarioResolver

  object :scenario_seed do
    field :id, non_null(:id)
    field :starting_state, non_null(:string)
  end

  object :scenario do
    field :id, non_null(:id)
    field :current_state, non_null(:string)
    field :available_moves, non_null(list_of(non_null(:move)))
  end

  object :move do
    @desc "The square where the piece was before (in algebraic notation)."
    #    TODO: possible to enumerate through all to get better type guarantees?
    field :square_from, non_null(:string)
    @desc "The square where the piece will be after the move (in algebraic notation)."
    field :square_to, non_null(:string)
    @desc "The team that get's to make this move."
    field :color, non_null(:string)
    @desc "The fen state if this move were to be made."
    field :fen_after_move, non_null(:string)
  end

  mutation do
    field :make_move, type: non_null(:scenario) do
      arg(:square_from, non_null(:string))
      arg(:square_to, non_null(:string))
      arg(:fen_after_move, non_null(:string))
      arg(:scenario_id, non_null(:id))

      resolve(&ScenarioResolver.make_move/3)
    end
  end

  subscription do
    field :move_made, type: non_null(:scenario) do
      arg(:scenario_id, non_null(:id))

      config(fn args, _info ->
        {:ok, topic: args.scenario_id}
      end)

      trigger(:make_move,
        topic: fn move ->
          move.id
        end
      )
    end
  end

  query do
    @desc "Get a specific scenario"
    field :scenario, non_null(:scenario) do
      arg(:scenario_id, non_null(:id))

      resolve(&ScenarioResolver.get/3)
    end

    @desc "Get all scenarios"
    field :scenario_seeds, non_null(list_of(non_null(:scenario_seed))) do
      resolve(&ScenarioResolver.all/3)
    end
  end
end

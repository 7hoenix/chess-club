defmodule ChessClubWeb.Schema do
  use Absinthe.Schema

  alias ChessClubWeb.ScenarioResolver

  object :scenario do
    field :id, non_null(:id)
    field :starting_state, non_null(:string)
    field :moves, non_null(list_of(non_null(:move)))
  end

  object :move do
    @desc "The square where the piece was before (in algebraic notation)."
#    TODO: possible to enumerate through all to get better type guarantees?
    field :square_from, non_null(:string)
    @desc "The square where the piece will be after the move (in algebraic notation)."
    field :square_to, non_null(:string)
  end

  mutation do
    field :make_move, :move do
      arg :square_from, non_null(:string)
      arg :square_to, non_null(:string)
      arg :scenario_id, non_null(:id)

      resolve &ScenarioResolver.make_move/3
    end
  end

  subscription do
    field :move_made, non_null(:move) do
      arg :scenario_id, non_null(:id)

      config fn args, _info ->
        {:ok, topic: args.scenario_id}
      end

      trigger :make_move, topic: fn move ->
        move.scenario_id
      end
    end
  end

  query do
    @desc "Get all scenarios"
    field :scenarios, non_null(list_of(non_null(:scenario))) do
      resolve(&ScenarioResolver.all/3)
    end
  end
end

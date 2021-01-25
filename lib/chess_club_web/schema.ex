defmodule ChessClubWeb.Schema do
  @moduledoc "Absinthe GraphQL schema"

  use Absinthe.Schema

  alias ChessClubWeb.ScenarioResolver

  object :scenario do
    field :id, non_null(:id)
    field :current_state, non_null(:string)
    field :available_moves, non_null(list_of(non_null(:move)))
  end

  object :move do
    @desc "The square where the piece was before (in algebraic notation)."
    # possible to enumerate through all to get better type guarantees?
    field :square_from, non_null(:string)
    @desc "The square where the piece will be after the move (in algebraic notation)."
    field :square_to, non_null(:string)
    @desc "The team that get's to make this move."
    field :color, non_null(:string)
    @desc "The move command that should be sent back to the backend."
    field :move_command, non_null(:string)
    @desc "The fen state if this move were to be made."
    field :fen_after_move, non_null(:string)
  end

  mutation do
    field :create_scenario, type: non_null(:scenario) do
      resolve(&ScenarioResolver.create/3)
    end

    field :make_move, type: non_null(:scenario) do
      arg(:move_command, non_null(:string))
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
        topic: fn scenario ->
          scenario.id
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
    field :scenarios, non_null(list_of(non_null(:scenario))) do
      resolve(&ScenarioResolver.all/3)
    end
  end

  def middleware(middleware, _field, %Absinthe.Type.Object{identifier: identifier})
      when identifier in [:query, :mutation, :subscription] do
    [ChessClubWeb.Middleware.Authentication | middleware]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end
end

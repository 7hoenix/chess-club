defmodule ChessClubWeb.Schema do
  use Absinthe.Schema

  alias ChessClubWeb.ScenarioResolver

  object :scenario do
    field :id, non_null(:id)
    field :starting_state, non_null(:string)
  end

  query do
    @desc "Get all scenarios"
    field :scenarios, non_null(list_of(non_null(:scenario))) do
      resolve(&ScenarioResolver.all/3)
    end
  end
end

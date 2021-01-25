defmodule ChessClub.Learn.Scenario do
  @moduledoc "Ecto schema for Scenarios"

  use Ecto.Schema

  import Ecto.Changeset

  alias ChessClub.Learn.Move

  schema "scenarios" do
    field :starting_state, :string
    has_many :moves, Move

    timestamps()
  end

  @required_fields [:starting_state]

  @doc false
  def changeset(scenario, attrs) do
    scenario
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end

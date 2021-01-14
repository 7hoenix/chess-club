defmodule ChessClub.Learn.Scenario do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChessClub.Learn.Move

  schema "scenarios" do
    field :starting_state, :string
    has_many :moves, Move

    timestamps()
  end

  @doc false
  def changeset(scenario, attrs) do
    scenario
    |> cast(attrs, [:starting_state])
    |> validate_required([:starting_state])
  end
end

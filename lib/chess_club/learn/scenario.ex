defmodule ChessClub.Learn.Scenario do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scenarios" do
    field :starting_state, :string

    timestamps()
  end

  @doc false
  def changeset(scenario, attrs) do
    scenario
    |> cast(attrs, [:starting_state])
    |> validate_required([:starting_state])
  end
end

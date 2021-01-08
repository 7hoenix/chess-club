defmodule ChessClub.Learn.Move do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChessClub.Learn.Scenario

  schema "moves" do
    field :square_from, :string
    field :square_to, :string
    belongs_to :scenario, Scenario

    timestamps()
  end

  @doc false
  def changeset(move, attrs) do
    move
    |> cast(attrs, [:square_from, :square_to, :scenario_id])
    |> validate_required([:square_from, :square_to, :scenario_id])
  end
end

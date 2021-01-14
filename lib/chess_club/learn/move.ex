defmodule ChessClub.Learn.Move do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChessClub.Learn.Scenario

  schema "moves" do
    field :move_command, :string
    belongs_to :scenario, Scenario

    timestamps()
  end

  @doc false
  def changeset(move, attrs) do
    move
    |> cast(attrs, [:move_command, :scenario_id])
    |> validate_required([:move_command, :scenario_id])
  end
end

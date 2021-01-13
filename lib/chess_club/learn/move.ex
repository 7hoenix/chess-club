defmodule ChessClub.Learn.Move do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChessClub.Learn.Scenario

  schema "moves" do
    field :square_from, :string
    field :square_to, :string
    # TODO: do we even need to store this? It's more of a frontend concern.
    field :fen_after_move, :string
    belongs_to :scenario, Scenario

    timestamps()
  end

  @doc false
  def changeset(move, attrs) do
    move
    |> cast(attrs, [:fen_after_move, :square_from, :square_to, :scenario_id])
    |> validate_required([:fen_after_move, :square_from, :square_to, :scenario_id])
  end
end

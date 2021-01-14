defmodule ChessClub.Repo.Migrations.CreateMoves do
  use Ecto.Migration

  def change do
    create table(:moves) do
      add :square_from, :string, size: 2
      add :square_to, :string, size: 2
      add :scenario_id, references(:scenarios)

      timestamps()
    end

    create index(:moves, [:scenario_id])
  end
end

defmodule ChessClub.Repo.Migrations.CreateScenarios do
  use Ecto.Migration

  def change do
    create table(:scenarios) do
      add :starting_state, :string

      timestamps()
    end

  end
end

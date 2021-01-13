defmodule ChessClub.Repo.Migrations.AddFenAfterMoveToScenarios do
  use Ecto.Migration

  def change do
    alter table(:moves) do
      add :fen_after_move, :string
    end
  end
end

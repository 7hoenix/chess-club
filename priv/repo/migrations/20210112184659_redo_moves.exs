defmodule ChessClub.Repo.Migrations.RedoMoves do
  use Ecto.Migration

  def change do
    alter table(:moves) do
      add :move_command, :string
      remove :square_from
      remove :square_to
    end
  end
end

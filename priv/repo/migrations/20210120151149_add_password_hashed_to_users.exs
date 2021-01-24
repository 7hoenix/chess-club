defmodule ChessClub.Repo.Migrations.AddPasswordHashedToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_hashed, :string
    end
  end
end

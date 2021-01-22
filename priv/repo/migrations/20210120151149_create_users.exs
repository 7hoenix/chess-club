defmodule ChessClub.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :password_hashed, :string

      timestamps()
    end
  end
end

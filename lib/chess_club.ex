defmodule ChessClub do
  @moduledoc """
  ChessClub keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias ChessClub.Repo

  @spec all(schema :: Ecto.Queryable) :: [Ecto.Changeset | Ecto.ChangeError]
  def all(schema) do
    Repo.all(schema)
  end
end

defmodule ChessClub.UserManager.User do
  use Ecto.Schema
  import Ecto.Changeset

  @required_attributes [:username, :password, :password_confirmation]

  schema "users" do
    field :password, :string, virtual: true
    field :password_hashed, :string
    field :username, :string

    field :password_confirmation, :string, virtual: true
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_attributes)
    |> validate_required(@required_attributes)
    |> validate_confirmation(:password, message: "Password does not match confirmation.")
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password_hashed: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end

defmodule ChessClub.UserManagerTest do
  use ChessClub.DataCase

  alias ChessClub.UserManager
  alias Argon2

  describe "users" do
    alias ChessClub.UserManager.User

    @valid_attrs %{
      password: "some password",
      password_confirmation: "some password",
      username: "some username"
    }
    @update_attrs %{
      password: "some updated password",
      password_confirmation: "some updated password",
      username: "some updated username"
    }
    @invalid_attrs %{password: nil, password_confirmation: nil, username: nil}
    @password_repeated_is_different %{
      password: "some password",
      password_confirmation: "not same",
      username: "some username"
    }

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> UserManager.create_user()

      user
    end

    defp remove_virtual_fields(user) do
      Map.merge(user, %{password: nil, password_confirmation: nil})
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert UserManager.list_users() == [remove_virtual_fields(user)]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert UserManager.get_user!(user.id) == remove_virtual_fields(user)
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = UserManager.create_user(@valid_attrs)
      assert {:ok, user} == Argon2.check_pass(user, "some password", hash_key: :password_hashed)
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserManager.create_user(@invalid_attrs)
    end

    test "create_user/1 with password confirmation that doesn't match throws error" do
      assert {:error, %Ecto.Changeset{}} =
               UserManager.create_user(@password_repeated_is_different)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = UserManager.update_user(user, @update_attrs)

      assert {:ok, user} ==
               Argon2.check_pass(user, "some updated password", hash_key: :password_hashed)

      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = UserManager.update_user(user, @invalid_attrs)

      assert remove_virtual_fields(user) == UserManager.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = UserManager.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> UserManager.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = UserManager.change_user(user)
    end
  end
end

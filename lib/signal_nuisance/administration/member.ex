defmodule SignalNuisance.Administration.Administrator do
    use Ecto.Schema

    import Ecto.Query
    import Ecto.Changeset

    alias SignalNuisance.Repo
    alias SignalNuisance.Accounts.User

    schema "administrators" do
      belongs_to :user, User
    end

    def registration_changeset(administrator, attrs) do
      administrator
      |> cast(attrs, [:user_id])
      |> foreign_key_constraint(:user_id, name: :enterprise_members_user_id_fkey)
      |> validate_required([:user_id])
    end

    def add(user) do
      with {:ok, _} <- %__MODULE__{}
      |> registration_changeset(%{user_id: user.id})
      |> Repo.insert
      do
        :ok
      end
    end

    def remove(user) do
        from(
            m in __MODULE__,
            where: m.user_id == ^user.id
        ) |> Repo.delete_all
        :ok
    end

    def is?(user) do
      from(
        m in __MODULE__,
        where: m.user_id == ^user.id
      ) |> Repo.one != nil
    end
  end

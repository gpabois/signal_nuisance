defmodule SignalNuisance.Administration.Authorization.UserPermission do
    use Ecto.Schema
    use Bitwise
    import Ecto.Changeset
    import Ecto.Query

    alias SignalNuisance.Repo
    alias SignalNuisance.Accounts.User
    alias SignalNuisance.Administration.Authorization.Permission, as: Permission

    use SignalNuisance.Authorization.Permission,
        permissions: Permission.permissions(),
        encoding: :byte

    schema "administration_user_permissions" do
        belongs_to :user,        User
        field :permissions,      :integer
    end

    def create(user, permissions) do
        with {:ok, _entry} <- %__MODULE__{
            user_id: user.id,
            permissions: encode_permission(permissions)
            } |> Repo.insert
        do
            :ok
        end
    end

    defp has_entry?(%{id: user_id} = _user, _permissions) do
        from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            select: count()
        ) |> Repo.one > 0
    end

    @doc """
        Grant enterprise-related permissions to a user.

        ## Parameters
        - entity: [user: user],
        - permissions
        - resource: [enterprise: enterprise]
    """
    def grant(user, permissions, _) do
        result = if not has_entry?(user, permissions) do
            create(user, permissions)
        else
            permissions = encode_permission(permissions)
            Repo.get_by(__MODULE__, user_id: user.id)
            |> change(%{permissions: permissions})
            |> Repo.update
        end

        case result do
            {:ok, _} -> :ok
            error -> error
        end
    end

    def revoke_all(user, _context) do
        from(
            perm in __MODULE__,
            where: perm.user_id == ^user.id
        ) |> Repo.delete_all
        :ok
    end

    def revoke(user, _permissions, _context) do
        from(
            perm in __MODULE__,
            where: perm.user_id == ^user.id
        ) |> Repo.delete_all
        :ok
    end

    def has?(user, permissions, _context) do
        %{id: user_id} = user
        permissions = encode_permission(permissions)

        from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            select: perm.permissions
        ) |> Repo.all |> Enum.any?(fn p -> (p &&& permissions) == permissions end)
    end
end

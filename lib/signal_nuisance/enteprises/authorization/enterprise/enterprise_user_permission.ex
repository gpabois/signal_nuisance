defmodule SignalNuisance.Enterprises.Authorization.EnterpriseUserPermission do
    use Ecto.Schema
    import Ecto.Changeset
    import Ecto.Query
  
    alias SignalNuisance.Repo
    alias SignalNuisance.Accounts.User
    alias SignalNuisance.Enterprises.Enterprise
    alias SignalNuisance.Enterprises.Authorization.EnterprisePermission, as: Permission

    schema "enterprise_user_permissions" do
        belongs_to :enterprise,  Enterprise
        belongs_to :user,       User
        field :permissions,     :integer
    end

    def create(user, enterprise, permissions) do
        permissions = Permission.encode_permission(permissions)
        with {:ok, _entry} <- %__MODULE__{
            enterprise_id: enterprise.id, 
            user_id: user.id, 
            permissions: permissions
            } |> Repo.insert 
        do
            :ok
        end
    end

    defp has_entry?(%{id: user_id} = _user, %{id: enterprise_id} = _enterprise, _permissions) do
        from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            where: perm.enterprise_id == ^enterprise_id,
            select: count()
        ) |> Repo.one > 0
    end

    def grant(user, enterprise, permissions) do
        result = if not has_entry?(user, enterprise, permissions) do
            create(user, enterprise, permissions)
        else
            permissions = Permission.encode_permission(permissions)
            Repo.get_by(__MODULE__, user_id: user.id, enterprise_id: enterprise.id)
            |> change(%{permissions: permissions})
            |> Repo.update
        end

        case result do
            {:ok, _} -> :ok
            error -> error
        end
    end

    def revoke_all(user, enterprise) do
        from(
            perm in __MODULE__,
            where: perm.user_id == ^user.id,
            where: perm.enterprise_id == ^enterprise.id
        ) |> Repo.delete_all
        :ok
    end

    def revoke(user, enterprise, _permissions) do
        from(
            perm in __MODULE__,
            where: perm.user_id == ^user.id,
            where: perm.enterprise_id == ^enterprise.id
        ) |> Repo.delete_all
        :ok
    end

    def has_permission?(%{id: user_id} = _user, %{id: enterprise_id} = _enterprise, permissions) do
        permissions = Permission.encode_permission(permissions)
        
        from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            where: perm.enterprise_id == ^enterprise_id,
            where: (perm.permissions and ^permissions) == ^permissions,
            select: count()
        ) |> Repo.one > 0
    end
end 
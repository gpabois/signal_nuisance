defmodule SignalNuisance.Enterprises.Authorization.EnterpriseUserPermission do
    use Ecto.Schema
    use Bitwise
    import Ecto.Changeset
    import Ecto.Query
  
    alias SignalNuisance.Repo
    alias SignalNuisance.Accounts.User
    alias SignalNuisance.Enterprises.Enterprise
    alias SignalNuisance.Enterprises.Authorization.EnterprisePermission, as: Permission

    use SignalNuisance.Authorization.Permission,
        permissions: Permission.permissions(),
        encoding: :byte

    schema "enterprise_user_permissions" do
        belongs_to :enterprise,  Enterprise
        belongs_to :user,        User
        field :permissions,      :integer
    end

    def create(user, enterprise, permissions) do
        with {:ok, _entry} <- %__MODULE__{
            enterprise_id: enterprise.id, 
            user_id: user.id, 
            permissions: encode_permission(permissions)
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

    @doc """
        Grant enterprise-related permissions to a user.

        ## Parameters
        - entity: [user: user],
        - resource: [enterprise: enterprise]
        - permission
        - ...
    """
    def grant(context) do
        permissions = context |> get_permissions
        user = context |> get_entities |> Keyword.fetch!(:user)
        enterprise = context |> get_resources |> Keyword.fetch!(:enterprise)

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

    def revoke_all(user) do
        from(
            perm in __MODULE__,
            where: perm.user_id == ^user.id,
            where: perm.enterprise_id == ^enterprise.id
        ) |> Repo.delete_all
        :ok
    end

    def revoke(context) do
        from(
            perm in __MODULE__,
            where: perm.user_id == ^user.id,
            where: perm.enterprise_id == ^enterprise.id
        ) |> Repo.delete_all
        :ok
    end

    def has_permission?(%{id: user_id} = _user, %{id: enterprise_id} = _enterprise, permissions) do
        permissions = encode_permission(permissions)
        
        stored = from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            where: perm.enterprise_id == ^enterprise_id,
            select: perm.permissions
        ) |> Repo.all |> Enum.any?(fn p -> (p &&& permissions) == permissions end)
    end
end 
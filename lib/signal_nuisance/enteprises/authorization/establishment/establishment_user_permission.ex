defmodule SignalNuisance.Enterprises.Authorization.EstablishmentUserPermission do
    use Ecto.Schema
    import Ecto.Changeset
    import Ecto.Query
  
    alias SignalNuisance.Repo
    alias SignalNuisance.Accounts.User
    alias SignalNuisance.Enterprises.Authorization.EstablishmentPermission, as: Permission
    alias SignalNuisance.Enterprises.Establishment

    schema "establishment_user_permissions" do
        belongs_to :establishment,  Establishment
        belongs_to :user,       User
        field :permissions,     :integer
    end

    def create(user, establishment, permissions) do
        permissions = Permission.encode_permission(permissions)
        with {:ok, _entry} <- %__MODULE__{
            establishment_id: establishment.id, 
            user_id: user.id, 
            permissions: permissions
            } |> Repo.insert 
        do
            :ok
        end
    end

    defp has_entry?(%{id: user_id} = _user, %{id: establishment_id} = _establishment, _permissions) do
        from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            where: perm.establishment_id == ^establishment_id,
            select: count()
        ) |> Repo.one > 0
    end

    def grant(user, establishment, permissions) do
        result = if not has_entry?(user, establishment, permissions) do
            create(user, establishment, permissions)
        else
            permissions = Permission.encode_permission(permissions)
            Repo.get_by(__MODULE__, user_id: user.id, establishment_id: establishment.id)
            |> change(%{permissions: permissions})
            |> Repo.update
        end 

        case result do
            {:ok, _} -> :ok
            error -> error
        end
    end

    def revoke_all(user, establishment) do
        from(
            perm in __MODULE__,
            where: perm.user_id == ^user.id,
            where: perm.establishment_id == ^establishment.id
        ) |> Repo.delete_all
        :ok
    end

    def revoke(user, establishment, _permissions) do
        from(
            perm in __MODULE__,
            where: perm.user_id == ^user.id,
            where: perm.establishment_id == ^establishment.id
        ) |> Repo.delete_all
        :ok
    end

    def revoke_all_by_enterprise(%{id: user_id} = _user, %{id: enterprise_id} = _enterprise) do
        from(
            p in __MODULE__,
            join: e in Establishment,
            on: e.id == p.establishment_id,
            where: e.enterprise_id == ^enterprise_id,
            where: p.user_id == ^user_id
        ) |> Repo.delete_all
        :ok
    end

    def has_permission?(%{id: user_id} = _user, %{id: establishment_id} = _establishment, permissions) do
        permissions = Permission.encode_permission(permissions)
        from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            where: perm.establishment_id == ^establishment_id,
            where: (perm.permissions and ^permissions) == ^permissions,
            select: count()
        ) |> Repo.one > 0
    end
end 
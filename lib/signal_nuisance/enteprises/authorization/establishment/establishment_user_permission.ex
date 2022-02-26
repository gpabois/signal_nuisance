defmodule SignalNuisance.Enterprises.Authorization.EstablishmentUserPermission do
    use Ecto.Schema
    use Bitwise

    import Ecto.Changeset
    import Ecto.Query

    alias SignalNuisance.Repo
    alias SignalNuisance.Accounts.User
    alias SignalNuisance.Enterprises.Authorization.EstablishmentPermission, as: Permission
    alias SignalNuisance.Enterprises.Establishment

    use SignalNuisance.Authorization.Permission,
        permissions: Permission.permissions(),
        encoding: :byte

    schema "establishment_user_permissions" do
        belongs_to :establishment,  Establishment
        belongs_to :user,       User
        field :permissions,     :integer
    end

    def create(user, establishment, permissions) do
        with {:ok, _entry} <- %__MODULE__{
            establishment_id: establishment.id,
            user_id: user.id,
            permissions: encode_permission(permissions)
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

    def grant({:user, user}, permissions, establishment) do
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

    def revoke({:user, user}, _permissions, establishment) do

        from(
            perm in __MODULE__,
            where: perm.user_id == ^user.id,
            where: perm.establishment_id == ^establishment.id
        ) |> Repo.delete_all
        :ok
    end

    def revoke_all({:user, user}, establishment) do
        case establishment do
            [{:by, [{:enterprise, enterprise}]}] ->
                revoke_all_by_enterprise(user, enterprise)
            establishment ->
                from(
                    perm in __MODULE__,
                    where: perm.user_id == ^user.id,
                    where: perm.establishment_id == ^establishment.id
                ) |> Repo.delete_all
        end
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

    def has?({:user, user}, permissions, establishment) do
        permissions = encode_permission(permissions)

        %{id: user_id} = user
        %{id: establishment_id} = establishment

        stored = from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            where: perm.establishment_id == ^establishment_id,
            select: perm.permissions
        ) |> Repo.all |> Enum.any?(fn x -> is_permission?(x, permissions) end)
    end
end

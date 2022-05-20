defmodule SignalNuisance.Facilities.Authorization.UserPermission do
    use Ecto.Schema
    use Bitwise

    import Ecto.Changeset
    import Ecto.Query

    alias SignalNuisance.Repo
    alias SignalNuisance.Accounts.User
    alias SignalNuisance.Facilities.Facility
    alias SignalNuisance.Facilities.Authorization.Permission, as: Permission

    use SignalNuisance.Authorization.Permission,
        permissions: Permission.permissions(),
        encoding: :byte

    schema "facility_user_permissions" do
        belongs_to :facility, Facility
        belongs_to :user, User
        field :permissions, :integer
    end

    def create(user, facility, permissions) do
        with {:ok, _entry} <- %__MODULE__{
            facility_id: facility.id,
            user_id: user.id,
            permissions: encode_permission(permissions)
            } |> Repo.insert
        do
            :ok
        end
    end

    defp has_entry?(%{id: user_id} = _user, %{id: facility_id} = _facility, _permissions) do
        from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            where: perm.facility_id == ^facility_id,
            select: count()
        ) |> Repo.one > 0
    end

    def grant(user, permissions, facility) do
        result = if not has_entry?(user, facility, permissions) do
            create(user, facility, permissions)
        else
            permissions = encode_permission(permissions)
            Repo.get_by(__MODULE__, user_id: user.id, facility_id: facility.id)
            |> change(%{permissions: permissions})
            |> Repo.update
        end

        case result do
            {:ok, _} -> :ok
            error -> error
        end
    end

    def revoke(user, _permissions, facility) do
        from(
            perm in __MODULE__,
            where: perm.user_id == ^user.id,
            where: perm.facility_id == ^facility.id
        ) |> Repo.delete_all
        :ok
    end

    def revoke_all(user, facility) do
        Repo.delete_all from(
            perm in __MODULE__,
            where: perm.user_id == ^user.id,
            where: perm.facility == ^facility.id
        )
        :ok
    end

    def has?(user, permissions, facility) do
        permissions = encode_permission(permissions)

        %{id: user_id} = user
        %{id: facility_id} = facility

        from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            where: perm.facility_id == ^facility_id,
            select: perm.permissions
        ) |> Repo.all |> Enum.any?(fn x -> is_permission?(x, permissions) end)
    end
end

defmodule SignalNuisance.Reporting.Authorization.AlertUserPermission do
    use Ecto.Schema

    alias SignalNuisance.Repo
    alias SignalNuisance.Reporting.Alert
    alias SignalNuisance.Accounts.User
    alias SignalNuisance.Reporting.Authorization.AlertPermission, as: Permission

    import Ecto.Query

    use SignalNuisance.Authorization.Permission,
        permissions: Permission.permissions(),
        encoding: :byte

    schema "alert_user_permissions" do
        belongs_to :alert, Alert
        belongs_to :user, User
        field :permissions, :integer
    end

    def grant({:user, user}, permissions, alert) do
        permissions = permissions |> encode_permission()

        with {:ok, _perm} <- %__MODULE__{
                alert_id: alert.id,
                user_id: user.id,
                permissions: permissions
            } |> Repo.insert
        do
            :ok
        end
    end

    def revoke_all(user, alert) do
        from(
            perm in __MODULE__,
            where: perm.user_id == ^user.id,
            where: perm.alert_id == ^alert.id
        ) |> Repo.delete_all

        :ok
    end

    def revoke({:user, user}, _permissions, alert) do
        %{id: alert_id} = alert
        %{id: user_id} = user

        from(p in __MODULE__,
            where: p.user_id == ^user_id,
            where: p.alert_id == ^alert_id
        ) |> Repo.delete_all
    end

    def has?({:user, user}, permissions, alert) do
        permissions = encode_permission(permissions)
        %{id: alert_id} = alert
        %{id: user_id} = user

        from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            where: perm.alert_id == ^alert_id,
            select: perm.permissions
        ) |> Repo.all() |> Enum.any?(fn x -> is_permission?(x, permissions) end)
    end
end

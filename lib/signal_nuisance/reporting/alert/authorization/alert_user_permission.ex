defmodule SignalNuisance.Reporting.Authorization.ReportUserPermission do
    alias SignalNuisance.Reporting.Authorization.AlertPermission, as: Permission
    use SignalNuisance.Authorization.Permission,
        permissions: Permission.permissions(),
        encoding: :byte

    use Ecto.Schema

    alias SignalNuisance.Repo
    alias SignalNuisance.Reporting.Alert
    alias SignalNuisance.Accounts.User

    import Ecto.Query
    import Ecto.Changeset

    schema "alert_user_permissions" do
        belongs_to :alert, Alert
        belongs_to :user, User
        field :permissions, :integer
    end

    def grant({:user, user}, permissions, context) do
        permissions = context |> get_permissions() |> encode_permissions()
        alert = context |> get_resource(:alert)

        with {:ok, _perm} <- %__MODULE__{
                alert_id: alert.id, 
                user_id: user.id, 
                permissions: permissions
            } |> Repo.insert 
        do
            :ok
        end
    end

    def revoke({:user, user}, _permissions, context) do
        %{id: alert_id} = context |> get_resource(:alert)
        %{id: user_id} = user

        from(p in __MODULE__,
            where: p.user_id == ^user_id,
            where: p.alert_id == ^alert_id
        ) |> Repo.delete_all
    end

    def has?({:user, user}, permissions, context) do
        permissions = context |> get_permissions() |> encode_permissions()
        %{id: alert_id} = context |> get_resource(:alert)
        %{id: user_id} = user

        from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            where: perm.alert_id == ^alert_id,
            select: perm.permissions
        ) |> Repo.all() |> Enum.any(&is_permission/2)
    end
end
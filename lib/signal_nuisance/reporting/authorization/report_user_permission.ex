defmodule SignalNuisance.Reporting.Authorization.ReportUserPermission do
    use Ecto.Schema

    alias SignalNuisance.Repo

    alias SignalNuisance.Reporting.Report
    alias SignalNuisance.Accounts.User
    alias SignalNuisance.Reporting.Authorization.ReportPermission, as: Permission

    import Ecto.Query
    import Ecto.Changeset

    schema "report_user_permissions" do
        belongs_to :report,  Report
        belongs_to :user,       User
        field :permissions,     :integer
    end

    def grant(user, report, permissions) do
        permissions = Permission.encode_permission(permissions)

        with {:ok, _perm} <- %__MODULE__{
                report_id: report.id, 
                user_id: user.id, 
                permissions: permissions
            } |> Repo.insert 
        do
            :ok
        end
    end

    def alter(user, report, permissions) do
        permissions = Permission.encode_permission(permissions)
        Repo.get_by(__MODULE__, user_id: user.id, report_id: report.id)
        |> change(%{permissions: permissions})
        |> Repo.update
    end

    def revoke(%{id: user_id} = _user, %{id: report_id} = _report) do
        from(p in __MODULE__,
            where: p.user_id == ^user_id,
            where: p.report_id == ^report_id
        ) |> Repo.delete_all
    end

    def has_permission?(%{id: user_id} = _user, %{id: report_id} = _report, permissions) do
        permissions = Permission.encode_permission(permissions)
        from(perm in __MODULE__,
            where: perm.user_id == ^user_id,
            where: perm.report_id == ^report_id,
            where: (perm.permissions and ^permissions) == ^permissions,
            select: count()
        )|> Repo.one > 0
    end
end
defmodule SignalNuisance.Reporting.Authorization.ReportTokenPermission do
    use Ecto.Schema

    alias SignalNuisance.Repo
    alias SignalNuisance.Reporting.Report
    alias SignalNuisance.Reporting.Authorization.ReportPermission, as: Permission

    import Ecto.Query
    import Ecto.Changeset

    schema "report_token_permissions" do
        belongs_to :report, Report
        field :secret_key,  :string
        field :permissions, :integer
    end

    def grant(report, permissions) do
        secret_key = :crypto.strong_rand_bytes(10)
        permissions = Permission.encode_permission(permissions)

        with {:ok, perm} <- %__MODULE__{
            report_id: report.id, 
            secret_key: secret_key, 
            permissions: permissions
        }|> Repo.insert 
        do
            {:ok, perm.secret_key}
        end
    end

    def alter(secret_key, permissions) do
        permissions = Permission.encode_permission(permissions)
        Repo.get_by(__MODULE__, secret_key: secret_key)
        |> change(%{permissions: permissions})
        |> Repo.update
    end

    def revoke_all(%{secret: secret_key} = _token, _report) do
        from(
            perm in __MODULE__,
            where: perm.secret_key == ^secret_key
        ) |> Repo.delete_all

        :ok
    end

    def revoke(%{secret: secret_key} = _token, _report, _permissions) do
        from(
            perm in __MODULE__,
            where: perm.secret_key == ^secret_key
        ) |> Repo.delete_all
        :ok
    end

    def has_permission?(%{secret: secret_key} = _token, %{id: report_id} = _report, permissions) do
        permissions = Permission.encode_permission(permissions)
        from(perm in __MODULE__,
            where: perm.secret_key == ^secret_key,
            where: perm.report_id == ^report_id,
            where: (perm.permissions and ^permissions) == ^permissions,
            select: count()
        ) |> Repo.one > 0
    end
end
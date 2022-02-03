defmodule SignalNuisance.Reporting.Authorization.ReportPermission do
    use SignalNuisance.Authorization.Permission

    alias SignalNuisance.Reporting.Authorization.ReportSecretKeyPermission
    alias SignalNuisance.Reporting.Authorization.ReportUserPermission

    def permissions(), do: [:read, :update, :close, :delete]

    def owner_permissions(), do: permissions()

    def has_permission?(user, reporting, permissions, wth) do
        case Keyword.fetch(wth, :secret_key) do
            {:ok, secret_key} -> ReportSecretKeyPermission.has_permission?(secret_key, reporting, permissions)
            _ -> ReportUserPermission.has_permission?(user, reporting, permissions)
        end
    end
end
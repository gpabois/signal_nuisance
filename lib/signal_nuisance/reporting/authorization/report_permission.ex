defmodule SignalNuisance.Reporting.Authorization.ReportPermission do
    use SignalNuisance.Authorization.Permission

    alias SignalNuisance.Reporting.Authorization.ReportTokenPermission
    alias SignalNuisance.Reporting.Authorization.ReportUserPermission

    def permissions(), do: [:read, :update, :close, :delete]

    def owner_permissions(), do: permissions()

    def permission_entity_dispatch(entity) do
        case entity do
            %SignalNuisance.Accounts.User{} -> ReportUserPermission
            %SignalNuisance.Reporting.Token{} -> ReportTokenPermission
        end
    end
end
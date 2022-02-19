defmodule SignalNuisance.Reporting.Authorization.AlertPermission do
    alias SignalNuisance.Reporting.Authorization.AlertTokenPermission
    alias SignalNuisance.Reporting.Authorization.AlertUserPermission
    
    use SignalNuisance.Authorization.Permission,
        permissions: [:read, :close],
        dispatch_by_entity: [
            token: AlertTokenPermission,
            user: AlertUserPermission
        ]

    def role_based(role) do
        case role do
            :owner -> [:read, :close, :comment]
            _ -> []
        end
    end
end
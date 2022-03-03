defmodule SignalNuisance.Reporting.Authorization.AlertPermission do
    alias SignalNuisance.Reporting.Authorization.AlertTokenPermission
    alias SignalNuisance.Reporting.Authorization.AlertUserPermission

    @permissions [:read, :close]
    
    use SignalNuisance.Authorization.Permission,
        permissions: @permissions,
        dispatch_by_entity: [
            {SignalNuisance.Accounts.User, AlertUserPermission},
            email: AlertTokenPermission            
        ]

end
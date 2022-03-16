defmodule SignalNuisance.Administration.Authorization.Permission do
    alias SignalNuisance.Reporting.Authorization.UserPermission

    @permissions [
        :access,
        manage: :alerts,
        manage: :users,
        manage: :enterprises,
        manage: :administration
    ]
    
    use SignalNuisance.Authorization.Permission,
        permissions: @permissions,
        dispatch_by_entity: [
            {SignalNuisance.Accounts.User, UserPermission}         
        ]
    
    
end
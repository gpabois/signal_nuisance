defmodule SignalNuisance.Enterprises.Authorization.EnterprisePermission do
    alias SignalNuisance.Enterprises.Authorization.EnterpriseUserPermission, as: UserPermission

    use SignalNuisance.Authorization.Permission,
        permissions: [
            :access, 
            :delete, 
            manage: :members,
            manage: :establishments
        ],
        dispatch_by_entity: [
            user: UserPermission
        ],
        roles: [
            administrator: [:access, :delete, manage: :members, manage: :establishments],
            employee: [:access] 
        ]
        
end 
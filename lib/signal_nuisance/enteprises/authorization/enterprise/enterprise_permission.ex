defmodule SignalNuisance.Enterprises.Authorization.EnterprisePermission do
    alias SignalNuisance.Enterprises.Authorization.EnterpriseUserPermission, as: UserPermission

    @permissions [
        access: :common,
        manage: :enterprise,
        manage: :members,
        manage: :establishments
    ]

    use SignalNuisance.Authorization.Permission,
        permissions: @permissions,
        dispatch_by_entity: [
            {SignalNuisance.Accounts.User, UserPermission}
        ],
        roles: [
            administrator: @permissions,
            employee: [access: :common]
        ]

end

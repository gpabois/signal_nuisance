defmodule SignalNuisance.Enterprises.Authorization.EnterprisePermission do
    alias SignalNuisance.Enterprises.Authorization.EnterpriseUserPermission, as: UserPermission

    use SignalNuisance.Authorization.Permission,
        permissions: [
            access: :common,
            manage: :members,
            manage: :establishments
        ],
        dispatch_by_entity: [
            {SignalNuisance.Accounts.User, UserPermission}
        ],
        roles: [
            administrator: [access: :common, manage: :members, manage: :establishments],
            employee: [access: :common]
        ]

end

defmodule SignalNuisance.Facilities.Authorization.Permission do
    alias SignalNuisance.Facilities.Authorization.UserPermission, as: UserPermission

    @permissions [
        manage: :facility,
        manage: :production,
        manage: :communication,
        manage: :members
    ]

    use SignalNuisance.Authorization.Permission,
        permissions: @permissions,
        dispatch_by_entity: [
            {SignalNuisance.Accounts.User, UserPermission}
        ],
        roles: [
            administrator: @permissions,
            employee: []
        ]
end

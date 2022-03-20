defmodule SignalNuisance.Administration.Authorization.Permission do
    alias SignalNuisance.Administration.Authorization.UserPermission

    @permissions [
        access: :administration,
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

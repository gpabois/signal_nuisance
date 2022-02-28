defmodule SignalNuisance.Enterprises.Authorization.EstablishmentPermission do
    alias SignalNuisance.Enterprises.Authorization.EstablishmentUserPermission, as: UserPermission

    @permissions [
        access: :common,
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
            employee: [access: :common]
        ]

    def revoke_all_by_enterprise(context) do
        case delegate_by_entity(context) do
            nil -> {:error, :unmanaged_or_no_entity}
            hdlr -> revoke_all_by_enterprise(context)
        end
    end
end

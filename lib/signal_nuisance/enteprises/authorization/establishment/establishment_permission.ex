defmodule SignalNuisance.Enterprises.Authorization.EstablishmentPermission do
    alias SignalNuisance.Enterprises.Authorization.EstablishmentUserPermission, as: UserPermission

    use SignalNuisance.Authorization.Permission,
        permissions: [:access, manage: :production, manage: :members],
        dispatch_by_entity: [user: UserPermission],
        roles: [
            owner:    [:access, manage: :production, manage: :members],
            employee: [:access] 
        ]

    def revoke_all_by_enterprise(context) do
        case delegate_by_entity(context) do 
            nil -> {:error, :unmanaged_or_no_entity}
            hdlr -> revoke_all_by_enterprise(context)
        end
    end
end 
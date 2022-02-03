defmodule SignalNuisance.Enterprises.Authorization.EstablishmentPermission do
    use SignalNuisance.Authorization.Permission

    alias SignalNuisance.Enterprises.Authorization.EstablishmentUserPermission, as: UserPermission

    def owner_permission(), do: permissions()
    def base_permission(), do: [:access]

    def permissions(), do: [
        :access, 
        manage: :production,
        manage: :members
    ]
    
    def permission_entity_dispatch(entity) do
        case entity do
            %SignalNuisance.Accounts.User{} -> UserPermission
        end
    end

    def revoke_all_by_enterprise(entity, enterprise) do
        case permission_entity_dispatch(entity) do
            nil -> raise "Unknown entity"
            entity_based -> entity_based.revoke_all_by_enterprise(entity, enterprise)
        end
    end
end 
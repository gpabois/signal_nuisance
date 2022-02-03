defmodule SignalNuisance.Enterprises.Authorization.EnterprisePermission do
    use SignalNuisance.Authorization.Permission

    alias SignalNuisance.Enterprises.Authorization.EnterpriseUserPermission, as: UserPermission

    def owner_permission(), do: permissions()
    def base_permission(), do: [:access]

    def permissions(), do: [
        :access, 
        :delete, 
        manage: :members,
        manage: :establishments
    ]

    def has_permission?(user, enterprise, permissions) do
        UserPermission.has_permission?(user, enterprise, permissions)
    end

    def grant(entity, establishment, permissions) do
        case entity do
            %SignalNuisance.Accounts.User{} -> UserPermission.grant(entity, establishment, permissions)
            _ -> raise "Unknown entity to grant permissions."
        end
    end

    def revoke_all(entity, establishment) do
        case entity do
            %SignalNuisance.Accounts.User{} -> UserPermission.revoke_all(entity, establishment)
            _ -> raise "Unknown entity to grant permissions."
        end
    end

    def revoke(entity, establishment, permissions) do
        case entity do
            %SignalNuisance.Accounts.User{} -> UserPermission.revoke(entity, establishment, permissions)
            _ -> raise "Unknown entity to grant permissions."
        end
    end
end 
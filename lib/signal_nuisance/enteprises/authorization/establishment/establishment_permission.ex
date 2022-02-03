defmodule SignalNuisance.Enterprises.Authorization.EstablishmentPermission do
    use SignalNuisance.Authorization.Permission

    alias SignalNuisance.Enterprises.Authorization.EstablishmentUserPermission, as: UserPermission
    alias SignalNuisance.Enterprises.Authorization.EnterprisePermission


    def owner_permission(), do: permissions()
    def base_permission(), do: [:access]

    def permissions(), do: [
        :access, 
        manage: :production,
        manage: :members
    ]

    @doc """
        Check if a user has an establishment-related permission.

        Always true, if the user has the enterprise's permission {:manage, :establishments}
    """
    def has_permission?(user, establishment, permissions) do
        EnterprisePermission.has_permission?(user, %{id: establishment.enterprise_id}, {:manage, :establishments}) 
        or UserPermission.has_permission?(user, establishment, permissions)
    end

    def grant(entity, establishment, permissions) do
        case entity do
            %SignalNuisance.Accounts.User{} -> UserPermission.grant(entity, establishment, permissions)
            _ -> raise "Unknown entity to grant permissions."
        end
    end

    def revoke_all_by_enterprise(entity, enterprise) do
        case entity do
            %SignalNuisance.Accounts.User{} -> UserPermission.revoke_all_by_enterprise(entity, enterprise)
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
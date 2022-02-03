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

    def permission_entity_dispatch(entity) do
        case entity do
            %SignalNuisance.Accounts.User{} -> UserPermission
        end
    end
end 
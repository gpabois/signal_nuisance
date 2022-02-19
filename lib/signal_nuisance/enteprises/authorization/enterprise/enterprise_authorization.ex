defmodule SignalNuisance.Enterprises.EnterpriseAuthorization do
    alias SignalNuisance.Enterprises.Authorization.EnterprisePermission
    alias SignalNuisance.Authorization
  
    use SignalNuisance.Context

    @doc false
    def can?(entity, context) do
      case EnteprisePermission.get_permissions(context) do
        [] -> false,
        permissions -> Permission.can?(entity, permissions, context) 
      end or Authorization.can?(entity, manage: :enterprises)
    end
  end
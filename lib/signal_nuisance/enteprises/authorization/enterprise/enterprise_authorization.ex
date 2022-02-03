defmodule SignalNuisance.Enterprises.EnterpriseAuthorization do
    alias SignalNuisance.Enterprises.Authorization.EnterprisePermission
    alias SignalNuisance.Authorization

    @doc false
    def can(entity, enterprise, opts \\ []) do
      case opts do
        [other | tail]  -> 
          if other in EnterprisePermission.permissions() do
            EnterprisePermission.has_permission?(entity, enterprise, other)
          else
            can(entity, enterprise, tail)
          end
        [] -> false
      end or Authorization.can(entity, manage: :enterprises)
    end
  end
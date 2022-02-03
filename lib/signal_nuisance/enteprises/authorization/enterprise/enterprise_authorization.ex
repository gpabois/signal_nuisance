defmodule SignalNuisance.Enteprises.EnterpriseAuthorization do
    alias SignalNuisance.Enterprises.Authorization.EnterprisePermission
  
    @doc false
    def can(user, enterprise, opts \\ []) do
      case opts do
        [other | tail]  -> 
          if other in EnterprisePermission.permissions() do
            EnterprisePermission.has_permission?(user, enterprise, other)
          else
            can(user, enterprise, tail)
          end
        [] -> false
      end
    end
  end
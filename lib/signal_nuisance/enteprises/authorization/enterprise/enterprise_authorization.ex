defmodule SignalNuisance.Enterprises.EnterpriseAuthorization do
    alias SignalNuisance.Enterprises.Authorization.EnterprisePermission
    alias SignalNuisance.Authorization
  
    use SignalNuisance.Context

    @doc false
    def can?(context) do
      EnterprisePermission.can?(context) or 
      Authorization.can(Context.get_entities(context) ++ [manage: :enterprises])
    end
  end
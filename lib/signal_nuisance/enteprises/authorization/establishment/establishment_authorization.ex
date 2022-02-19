defmodule SignalNuisance.Enterprises.EstablishmentAuthorization do
    alias SignalNuisance.Enterprises.Authorization.EstablishmentPermission
    alias SignalNuisance.Authorization

    use SignalNuisance.Context

    def can?(entity, context) do
      EstablishmentPermission.can?(context)
      or Authorization.can(get_entities(context)
        ++ [resource(enterprise: %{id: establishment.enterprise_id})]
        ++ [manage: :establishments)]
      )
    end 
  end
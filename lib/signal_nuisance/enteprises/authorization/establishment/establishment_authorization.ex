defmodule SignalNuisance.Enterprises.EstablishmentAuthorization do
    alias SignalNuisance.Enterprises.Authorization.EstablishmentPermission
    alias SignalNuisance.Authorization

    def can(entity, establishment, opts \\ []) do
      case opts do
        [{:access, :dashboard} | _] -> can(entity, establishment, [:access])
        [{:do, :toggle_production}] -> can(entity, establishment, [{:manage, :production}])
        [other | tail] ->
          if other in  EstablishmentPermission.permissions() do
            EstablishmentPermission.has_permission?(entity, establishment, other)
          else
            can(entity, establishment, tail)
          end
        [] -> false
      end or Authorization.can(entity, enterprise: %{id: establishment.enterprise_id}, manage: :establishments) 
    end 
  end
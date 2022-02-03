defmodule SignalNuisance.Enteprises.EstablishmentAuthorization do
    alias SignalNuisance.Enterprises.Authorization.EstablishmentPermission
  
    @doc false
    def can(user, establishment, opts \\ []) do
      case opts do
        [{:access, :dashboard} | _] -> can(user, establishment, [:access])
        [{:do, :toggle_production}] -> can(user, establishment, [{:manage, :production}])
        [other | tail] ->
          if other in  EstablishmentPermission.permissions() do
            EstablishmentPermission.has_permission?(user, establishment, other)
          else
            can(user, establishment, tail)
          end
        [] -> false
      end
    end
  end
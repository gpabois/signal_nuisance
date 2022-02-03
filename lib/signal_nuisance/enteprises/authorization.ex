defmodule SignalNuisance.Enteprises.Authorization do   
    alias SignalNuisance.Enteprises.EnterpriseAuthorization
    alias SignalNuisance.Enteprises.EstablishmentAuthorization

    @resource_based %{
      enterprise:     EnterpriseAuthorization,
      establishment:  EstablishmentAuthorization
  }

    @doc false
    def can(user, %type{} = enterprise_or_establishment, opts \\ []) do
      authz = @resource_based[type]
      authz.can(user, enterprise_or_establishment, opts)
    end
  end
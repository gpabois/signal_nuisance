defmodule SignalNuisance.Enterprises.Authorization do   
    alias SignalNuisance.Enteprises.EnterpriseAuthorization
    alias SignalNuisance.Enteprises.EstablishmentAuthorization


    @doc false
    def can(user, %type{} = enterprise_or_establishment, opts \\ []) do
      authz = case type do
        SignalNuisance.Enterprises.Enterprise -> EnterpriseAuthorization
        SignalNuisance.Enterprises.Establishment -> EstablishmentAuthorization
      end
      authz.can(user, enterprise_or_establishment, opts)
    end
  end
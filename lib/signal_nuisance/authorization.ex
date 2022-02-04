defmodule SignalNuisance.Authorization do
    @resource_based %{
        enterprise:     SignalNuisance.Enterprises.EnterpriseAuthorization,
        establishment:  SignalNuisance.Enterprises.EstablishmentAuthorization,
        alert:          SignalNuisance.Reporting.AlertAuthorization
    }

    def resource_dispatch(context) do 
        case opts |> Enum.filter(fn ({k, _v}) -> Map.has_key?(@resource_based, k) end) do
            @resource_based[resource_type]
            [] -> nil
        end
    end

    @doc """
        Check if, based on the context, the action can be performed.

        ## Examples
        iex> Authorization.can user: user, enterprise: enterprise, access: :dashboard
    """
    def can?(context) do
        case resource_dispatch(context) do
            nil -> false
            hdlr -> hdlr.can?(context)
        end
    end

end
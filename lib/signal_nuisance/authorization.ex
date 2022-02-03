defmodule SignalNuisance.Authorization do

    @resource_based %{
        enterprise:     SignalNuisance.Enterprises.Authorization,
        establishment:  SignalNuisance.Enterprises.Authorization,
        reporting:      SignalNuisance.Reporting.Authorization
    }

    def can(user, opts \\ []) do
        case opts |> Enum.filter(fn ({k, _v}) -> Map.has_key?(@resource_based, k) end) do
            [{resource_type, resource}] -> @resource_based[resource_type].can(user, resource, opts)
            [] -> false
        end
    end

    # user |> can access: :dashboard, enterprise: tartampion
    # Authorization.can 
    # user |> can access: :report, reporting: blabla, with: [secret_key: sk]
end
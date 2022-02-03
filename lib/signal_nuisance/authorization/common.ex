defmodule SignalNuisance.Authorization.CommonPermission do
    use SignalNuisance.Authorization.Permission

    def permissions(), do: [
        {:create, :report}
    ]
    
    def has_permission?(_user, type) do
        case type do
            {:create, :report} -> true
            _ -> false
        end
    end
end
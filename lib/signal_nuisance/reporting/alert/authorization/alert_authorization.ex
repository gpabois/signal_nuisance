defmodule SignalNuisance.Reporting.AlertAuthorization do
    alias SignalNuisance.Reporting.Authorization.AlertPermission

    def can?(context) do
        AlertPermission.has?(context)
    end
end
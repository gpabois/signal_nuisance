defmodule SignalNuisanceWeb.Establishment do
    alias SignalNuisance.Enterprises

    def extract_establishment(%{path_params: %{"slug" => slug}} = _conn) do
        Enterprises.get_establishment_by_slug(slug)
    end
end
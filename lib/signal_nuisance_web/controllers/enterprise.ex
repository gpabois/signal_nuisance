defmodule SignalNuisanceWeb.Enterprise do
    alias SignalNuisance.Enterprises
    
    def extract_enterprise(%{path_params: %{"slug" => slug}} = _conn) do
        Enterprises.get_enterprise_by_slug(slug)
    end
end
defmodule SignalNuisanceWeb.EnterpriseDashboardController do
    use SignalNuisanceWeb, :controller
  
    alias SignalNuisance.Enterprises
    
    def extract_enterprise(%{params: %{slug: slug}} = _conn) do
        Enterprises.get_enterprise_by_slug(slug)
    end

    plug Bodyguard.Plug.Authorize,
      policy: SignalNuisance.Enterprises.SecurityPolicy,
      action: {:access, :view, :dashboard},
      user:   {SignalNuisanceWeb.UserAuth, :get_current_user},
      params: &__MODULE__.extract_enterprise/1,
      fallback: SignalNuisanceWeb.UnauthorizedController

    def show(%{assign: %{current_user: _user}} = conn) do
        render(conn, "show.html")
    end
end
defmodule SignalNuisanceWeb.EnterpriseDashboardController do
    use SignalNuisanceWeb, :controller
  
    alias SignalNuisance.Enterprises

    import SignalNuisanceWeb.Enterprise
    
    plug Bodyguard.Plug.Authorize,
      policy: SignalNuisance.Enterprises.SecurityPolicy,
      action: {:access, :view, :dashboard},
      user:   {SignalNuisanceWeb.UserAuth, :get_current_user},
      params: {SignalNuisanceWeb.Enterprise, :extract_enterprise},
      fallback: SignalNuisanceWeb.ErrorController

    def show(conn, _args) do
        render conn, "show.html", 
            enterprise: extract_enterprise(conn)
    end
end
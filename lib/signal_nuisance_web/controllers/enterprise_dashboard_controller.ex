defmodule SignalNuisanceWeb.EnterpriseDashboardController do
    use SignalNuisanceWeb, :controller
  
    alias SignalNuisance.Enterprises, as: Ets
    alias SignalNuisance.Enterprises.SecurityPolicy, as: EtsSecPol
    import SignalNuisanceWeb.Enterprise
    
    plug Bodyguard.Plug.Authorize,
      policy: SignalNuisance.Enterprises.SecurityPolicy,
      action: {:access, :view, :dashboard},
      user:   {SignalNuisanceWeb.UserAuth, :get_current_user},
      params: {SignalNuisanceWeb.Enterprise, :extract_enterprise},
      fallback: SignalNuisanceWeb.ErrorController
    
    def show(%{assigns: %{current_user: user}} = conn, _args) do
        enterprise = extract_enterprise(conn)
        establishments = Ets.get_establishment_by_enterprises enterprise,
          filter: EtsSecPol.w_permit?({:access, :view, :dashboard}, user)

        render conn, "show.html", 
            current_user: user,
            enterprise: enterprise,
            establishments: establishments,
            can: %{
              register_establishment?: EtsSecPol.permit?({:access, :view, :register_establishment}, user, enterprise)
            },
            page_title: gettext("Tableau de bord %{enterprise_name}", enterprise_name: enterprise.name)
    end
end
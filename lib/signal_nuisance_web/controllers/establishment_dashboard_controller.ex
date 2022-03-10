defmodule SignalNuisanceWeb.EstablishmentDashboardController do
  use SignalNuisanceWeb, :controller

  import SignalNuisanceWeb.Establishment

  plug Bodyguard.Plug.Authorize,
    policy: SignalNuisance.Enterprises.SecurityPolicy,
    action: {:access, :view, :dashboard},
    user:   {SignalNuisanceWeb.UserAuth, :get_current_user},
    params: {SignalNuisanceWeb.Establishment, :extract_establishment},
    fallback: SignalNuisanceWeb.ErrorController

  def show(conn, _args) do
      render(conn, "show.html", establishment: extract_establishment(conn))
  end
end
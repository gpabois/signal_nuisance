defmodule SignalNuisanceWeb.FacilityDashboardLive do
    alias Phoenix.LiveView.JS

    use SignalNuisanceWeb, :map_live_view

    alias SignalNuisance.Facilities

    def mount(_params, session, socket) do
        {:ok,
            socket
        }
    end

end

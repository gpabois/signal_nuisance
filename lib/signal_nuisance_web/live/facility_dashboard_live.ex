defmodule SignalNuisanceWeb.FacilityDashboardLive do
    alias Phoenix.LiveView.JS

    use SignalNuisanceWeb, :map_live_view

    def mount(_params, _session, socket) do
        {:ok,
            socket
            |> assign(:display_drawer, false)
            |> assign(:map_center, %{lat: 48.856614, long: 2.3522219})
            |> assign(:markers, [])
        }
    end

end

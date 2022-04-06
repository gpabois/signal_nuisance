defmodule SignalNuisanceWeb.ReportingLive do
    alias Phoenix.LiveView.JS

    use SignalNuisanceWeb, :map_live_view

    alias SignalNuisance.Enterprises
    alias SignalNuisance.Reporting
    alias SignalNuisance.Reporting.Alert

    def mount(_params, session, socket) do
        {:ok,
            socket
            |> assign(:map_center, %{lat: 48.856614, long: 2.3522219})
            |> assign(:user_loc, %{lat: nil, long: nil})
            |> assign(:markers, [])
            |> assign(:display_drawer, false)
            |> assign(:display_user_menu, false)
            |> assign(:alert_categories, SignalNuisance.Reporting.AlertType.categories())
            |> assign(:alert_form_step, 0)
            |> assign(:alert_changeset, nil)
            |> assign(:alert_types, [])
            |> assign(:current_user, session["current_user"])
            |> assign(:enterprises, Enterprises.get_enterprises_by_member(session["current_user"]))
        }
    end

    def update_markers(%{assigns: %{map_bounds: {ll, ur}}} = socket) do
        socket
        |> assign(
            :markers,
            Enum.map(
                Enterprises.get_establishments_in_area(ll, ur),
                fn ets -> %{type: "establishment", coordinates: ets.loc, id: ets.id} end
            )
        )
    end

    def handle_event("toggle-user-menu", _, socket) do
        {:noreply,
        socket |> assign(:display_user_menu, !socket.assigns.display_user_menu)
    }
    end

    def handle_event("marker-clicked", _marker, socket) do
        {:noreply, socket}
    end

    def handle_event("user-loc-update", %{"lat" => lat, "long" => long}, socket) do
        {:noreply,
            socket
            |> assign(:user_loc, %{lat: lat, long: long})
        }

    end

    def handle_event("map-bounds-update", box_coords, socket) do
        %{
            "_northEast" => %{
                "lat" => lat_ur,
                "lng" => long_ur
            },
            "_southWest" => %{
                "lat" => lat_ll,
                "lng" => long_ll
            }
        } = box_coords

        ur = %Geo.Point{
            coordinates: {lat_ur, long_ur},
            srid: 4326
        }

        ll = %Geo.Point{
            coordinates: {lat_ll, long_ll},
            srid: 4326
        }

        {:noreply, socket
            |> assign(:map_bounds, {ll, ur})
            |> update_markers()
        }
    end

    def handle_event("open-alert-form", _, socket) do
        {:noreply,
            socket
            |> assign(:alert_form_step, :"select-category")
        }
    end

    def handle_event("close-alert-form", _, socket) do
        {:noreply,
            socket
            |> assign(:alert_form_step, 0)
        }
    end

    def handle_event("select-alert-category", %{"category" => category}, socket) do
        changeset =
        %Alert{}
        |> Reporting.alert_creation_changeset()

        alert_types = Reporting.get_alert_types_by_category(category)

        {:noreply,
            socket
            |> assign(:alert_category, category)
            |> assign(:alert_types, alert_types)
            |> assign(:alert_changeset, changeset)
            |> assign(:alert_form_step, :main)
        }
    end

    def handle_event("validate-alert", %{"alert" => alert_params}, socket) do
        changeset =
        %Alert{}
            |> Reporting.alert_creation_changeset(alert_params)
            |> Map.put(:action, :insert)

        {:noreply,
            socket
            |> assign(:alert_changeset, changeset)
        }
    end

    def handle_event("create-alert", %{"alert" => alert_params}, socket) do
        alert_params = Map.merge(
            alert_params,
            %{"loc_lat" => socket.assigns.user_loc.lat, "loc_long" => socket.assigns.user_loc.long}
        )

        case Reporting.create_alert(alert_params) do
            {:ok, _alert} ->
                {:noreply,
                    socket
                        |> put_flash(:info, gettext("Signalement enregistré"))
                        |> assign(:display_alert_form, false)
                }
            {:error, changeset} ->
                {:noreply,
                    socket
                        |> put_flash(:error, gettext("Le signalement ne peut pas être enregistré."))
                        |> assign(:alert_changeset, changeset)
                }

        end
    end
end

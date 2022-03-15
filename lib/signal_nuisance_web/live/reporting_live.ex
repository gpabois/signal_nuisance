defmodule SignalNuisanceWeb.ReportingLive do
    use SignalNuisanceWeb, :live_view

    alias SignalNuisance.Reporting
    alias SignalNuisance.Reporting.Alert

    def mount(_params, session, socket) do
        {:ok, 
            socket
            |> assign(:display_alert_form, false)
            |> assign(:alert_form_step, 0)
            |> assign(:alert_changeset, nil)
            |> assign(:alert_types, [])
            |> assign(:current_user, session["current_user"])
        }
    end
    
    def handle_event("open-alert-form", _, socket) do
        {:noreply, 
            socket
            |> assign(:display_alert_form, true)
            |> assign(:alert_form_step, :"select-category")
        }
    end

    def handle_event("close-alert-form", _, socket) do
        {:noreply, 
            socket
            |> assign(:display_alert_form, false)
        }
    end

    def handle_event("select-alert-category", %{"category" => category}, socket) do
        changeset =
        %Alert{}
        |> Reporting.alert_creation_changeset()

        alert_types = Reporting.get_alert_types_by_category(category)

        IO.inspect(changeset)
        {:noreply, 
            socket
            |> assign(:alert_category, category)
            |> assign(:alert_types, alert_types)
            |> assign(:alert_changeset, changeset)
            |> assign(:alert_form_step, :"main-form")
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
        case Reporting.create_alert(alert_params) do
            {:ok, alert} ->
                {:noreply, 
                    socket
                        |> put_flash(:info, "Alert created.")
                        |> assign(:display_alert_form, false)
                }
            {:error, changeset} ->
                {:noreply, 
                    socket
                        |> assign(:alert_changeset, changeset)
                }

        end
    end
end
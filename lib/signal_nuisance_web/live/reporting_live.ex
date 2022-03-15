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

    def handle_even("close-alert-form", _, socket) do
        {:noreply, 
            socket
            |> assign(:display_alert_form, false)
        }
    end

    def handle_event("select-alert-category", %{"category" => category}, socket) do
        {:noreply, 
            socket
            |> assign(:alert_category, category)
            |> assign(:alert_types, Reporting.get_alert_types_by_category(category))
            |> assign(:alert_changeset, Reporting.alert_creation_changeset(%Alert{}))
            |> assign(:alert_form_step, :"main-form")
        }
    end

    def handle_event("validate-alert", %{"reporting" => reporting}, socket) do
        
    end

    def handle_event("create-alert", %{"reporting" => reporting}, socket) do

    end
end
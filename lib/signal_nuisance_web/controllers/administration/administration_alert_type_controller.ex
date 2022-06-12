defmodule SignalNuisanceWeb.Administration.AdministrationAlertTypeController do
    use SignalNuisanceWeb, :controller

    alias SignalNuisance.Administration.SecurityPolicy, as: SecPol
    alias SignalNuisance.Reporting
    alias SignalNuisance.Reporting.AlertType

    action_fallback SignalNuisanceWeb.FallbackController

    def index(conn, params) do
        user = conn.assigns.current_user

        with :ok <- Bodyguard.permit(SecPol, {:view, :alert_types}, user, {}) do
            {alert_types, pagination} = Reporting.paginate_alert_types(params)
            conn
            |> render("index.html", alert_types: alert_types, pagination: pagination)
        end
    end

    def new(conn, _params) do
        user = conn.assigns.current_user

        with :ok <- Bodyguard.permit(SecPol, {:view, :alert_types}, user, {}) do
            changeset = Reporting.alert_type_creation_changeset(%AlertType{})
            conn
            |> render("new.html", changeset: changeset)
        end
    end

    def create(conn, %{"alert_type" => alert_type_params}) do
        user = conn.assigns.current_user

        with :ok <- Bodyguard.permit(SecPol, {:create, :alert_type}, user, {}) do
            case Reporting.create_alert_type(alert_type_params) do
                {:ok, alert_type} ->
                    conn
                    |> put_flash(:info, "Type de nuisance crée avec succés.")
                    |> redirect(to: Routes.administration_alert_type_path(conn, :index))

                {:error, %Ecto.Changeset{} = changeset} ->
                    render(conn, "new.html", changeset: changeset)
            end
        end
    end

    def edit(conn, %{"id" => id}) do
        user = conn.assigns.current_user
        alert_type = Reporting.get_alert_type!(id)

        with :ok <- Bodyguard.permit(SecPol, {:edit, :alert_type}, user, {}) do
            changeset = Reporting.change_alert_type(alert_type)
            conn
            |> render("edit.html", changeset: changeset)
        end
    end

    def update(conn, %{"id" => id, "alert_type" => alert_type_params}) do
        user = conn.assigns.current_user
        alert_type = Reporting.get_alert_type!(id)

        with :ok <- Bodyguard.permit(SecPol, {:edit, :alert_type}, user, {}) do
            case Reporting.update_alert_type(alert_type, alert_type_params) do
                {:ok, _alert_type} ->
                    conn
                    |> put_flash(:info, "Type de nuisance crée avec succés.")
                    |> redirect(to: Routes.administration_alert_type_path(conn, :index))

                {:error, %Ecto.Changeset{} = changeset} ->
                    render(conn, "edit.html", changeset: changeset)
            end
        end
    end

    def delete(conn, %{"id" => id}) do
        user = conn.assigns.current_user
        alert_type = Reporting.get_alert_type!(id)

        with :ok <- Bodyguard.permit(SecPol, {:delete, :alert_type}, user, alert_type),
            {:ok, _} <- Reporting.delete_alert_type(alert_type) do
            conn
            |> put_flash(:info, "Le type de nuisance a été supprimé avec succés.")
            |> redirect(to: Routes.administration_alert_type_path(conn, :index))
        end
    end
end

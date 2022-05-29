defmodule SignalNuisanceWeb.Administration.AdministrationFacilityController do
    use SignalNuisanceWeb, :controller

    alias SignalNuisance.Administration.SecurityPolicy, as: SecPol
    alias SignalNuisance.Facilities

    def index(conn, params) do
        user = conn.assigns.current_user

        with :ok <- Bodyguard.permit(SecPol, {:view, :facilities}, user {}) do
            {facilities, pagination} = Facilities.paginate_facilities(params)
            conn
            |> render("index.html", facilities: facilities, pagination: pagination)
        end
    end

    def toggle_validation(conn, %{id: id}) do
        user = conn.assigns.current_user 
        facility = Facilities.get_facility!(id)

        with :ok <- Bodyguard.permit(SecPol, {:validate, :facility}, user, facility),
            {:ok, facility} <- Facilities.update_facility(facility, %{valid: !facility.valid}) do
                conn
                |> put_flash(:info, "Bascule de la validation effectuée avec succés.")
                |> redirect(to: administration_facility_path(conn, :show, facility))
        end
    end

    def show(conn, %{id: id}) do
        user = conn.assigns.current_user 
        facility = Facilities.get_facility!(id)

        with :ok <- Bodyguard.permit(SecPol, {:viex, :facility}, user, facility) do
            conn
            |> render("show.html", facility: facility)
        end        
    end
end
defmodule SignalNuisanceWeb.FacilityRegistrationController do
    use SignalNuisanceWeb, :controller

    alias SignalNuisance.Facilities
    alias SignalNuisance.Facilities.FacilityForm

    def new(conn, _params) do
      changeset = FacilityForm.registration_changeset(%FacilityForm{}, %{})
      render(conn, "new.html", changeset: changeset)
    end

    def create(%{assigns: %{current_user: user}} = conn, %{"facility" => params}) do
        params = FacilityForm.registration_changeset(%FacilityForm{}, params) |> FacilityForm.to_facility_attributes

        case Facilities.register(params, user) do
          {:ok, facility} ->
            conn
            |> put_flash(:info, "L'installation a été enregistrée avec succés, la demande sera examinée par un administrateur.")
            |> redirect(to: Routes.facility_dashboard_path(conn, :dashboard, facility.id))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
      end
end

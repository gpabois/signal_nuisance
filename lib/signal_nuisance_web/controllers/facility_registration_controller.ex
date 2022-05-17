defmodule SignalNuisanceWeb.FacilityRegistrationController do
    use SignalNuisanceWeb, :controller
  
    alias SignalNuisance.Facilities
    alias SignalNuisance.Facilities.Facility
    
    def new(conn, _params) do
      changeset = Enterprises.enterprise_registration_changeset(%Enterprise{}, %{})
      render(conn, "new.html", changeset: changeset)
    end

    def create(%{assigns: %{current_user: user}} = conn, %{"facility" => params}) do
        case Facilities.register(params, user) do
          {:ok, facility} ->
            conn
            |> put_flash(:info, "L'installation a été enregistrée avec succés.")
            |> redirect(to: Routes.enterprise_dashboard_path(conn, :show, enterprise.slug))
    
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
      end
end
defmodule SignalNuisanceWeb.EnterpriseRegistrationController do
    use SignalNuisanceWeb, :controller
  
    alias SignalNuisance.Enterprises
    alias SignalNuisance.Enterprises.Enterprise
    
    def new(conn, _params) do
      changeset = Enterprises.enterprise_registration_changeset(%Enterprise{}, %{})
      render(conn, "new.html", changeset: changeset)
    end

    def create(%{assign: %{current_user: user}} = conn, %{"enterprise" => enterprise_params}) do
        case Enterprises.register_enterprise(enterprise_params, user) do
          {:ok, enterprise} ->
            conn
            |> put_flash(:info, "Enterprise created successfully.")
            |> redirect(Routes.enterprise_dashboard_path(conn, :show, enterprise.slug))
    
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
      end
end
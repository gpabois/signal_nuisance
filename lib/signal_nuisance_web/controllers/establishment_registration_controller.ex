defmodule SignalNuisanceWeb.EstablishmentRegistrationController do
    use SignalNuisanceWeb, :controller
    
    alias SignalNuisance.Enterprises
    alias SignalNuisance.Enterprises.Establishment


    action_fallback SignalNuisanceWeb.ErrorController

    plug Bodyguard.Plug.Authorize,
      policy: SignalNuisance.Enterprises.SecurityPolicy,
      action: {:access, :view, :register_establishment},
      user:   {SignalNuisanceWeb.UserAuth, :get_current_user},
      params: {SignalNuisanceWeb.Enterprise, :extract_enterprise},
      fallback: SignalNuisanceWeb.ErrorController

    def new(conn, %{"slug" => slug} = _params) do
      changeset = Enterprises.establishment_registration_changeset(%Establishment{}, %{})
      enterprise = Enterprises.get_enterprise_by_slug(slug)
      render(conn, "new.html", changeset: changeset, enterprise: enterprise)
    end

    def create(%{assigns: %{current_user: user}} = conn, %{"slug" => slug, "establishment" => establishment_params}) do
      enterprise = Enterprises.get_enterprise_by_slug(slug)
      establishment_params = establishment_params |> Map.put("enterprise_id", enterprise.id)

      with :ok <- Bodyguard.permit(SignalNuisance.Enterprises.SecurityPolicy, :register_establishment, user, enterprise) do
        case Enterprises.register_establishment(establishment_params, user) do
            {:ok, establishment} ->
              conn
              |> put_flash(:info, "Establishment created successfully.")
              |> redirect(to: Routes.establishment_dashboard_path(conn, :show, establishment.slug))
      
            {:error, %Ecto.Changeset{} = changeset} ->
              render(conn, "new.html", changeset: changeset)
          end
        end
      end
end
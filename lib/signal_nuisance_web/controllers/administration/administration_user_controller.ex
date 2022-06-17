defmodule SignalNuisanceWeb.Administration.AdministrationUserController do
    use SignalNuisanceWeb, :controller

    alias SignalNuisance.Administration.SecurityPolicy, as: SecPol
    alias SignalNuisance.Facilities

    action_fallback SignalNuisanceWeb.FallbackController

    def index(conn, params) do
        admin = conn.assigns.current_user

        filter_changeset = %{} |> Accounts.users_filter_changeset(Map.get(params, "filter", %{}))
        filter = Accounts.filter_user(filter_changeset)

        with :ok <- Bodyguard.permit(SecPol, {:view, :users}, admin, {}) do
            {users, pagination} = Accounts.paginate_users(params, filter: filter)
            conn
            |> render("index.html", users: users, pagination: pagination, filter: filter_changeset)
        end
    end

    def show(conn, %{"id" => id}) do
        admin = conn.assigns.current_user
        user = Accounts.get_user!(id)

        with :ok <- Bodyguard.permit(SecPol, {:view, :user}, admin, user) do
            conn
            |> render("show.html", user: user)
        end
    end

    def delete(conn, %{"id" => id}) do
        admin = conn.assigns.current_user
        user = Accounts.get_user!(id)

        with :ok <- Bodyguard.permit(SecPol, {:delete, :user}, admin, user),
            {:ok, _} <- Accounts.delete_user(user) do
            conn
            |> put_flash(:info, "L'utilisateur a été supprimée avec succés.")
            |> redirect(to: Routes.administration_user_path(conn, :index))
        end
    end
end

defmodule SignalNuisanceWeb.AlertCreationController do
    use SignalNuisanceWeb, :controller

    alias SignalNuisance.Reporting
    alias SignalNuisance.Reporting.Alert

    @doc """
        New in case
    """
    def new(%{assigns: %{current_user: user}} = conn, args) do
        case  conn do
            %{assigns: %{current_user: user}} ->
                new_authenticated(conn, args)
            _ ->
                new_anonymous(conn, args)
        end
    end

    def new_authenticated(conn, _args) do
        render conn, "show_authenticated.html", changeset: Reporting.alert_creation_changeset(%Alert{})
    end

    def new_anonymous(conn, _args) do
    end

    def create(%{assigns: %{current_user: user}} = conn, args) do
        case  conn do
            %{assigns: %{current_user: user}} ->
                create_authenticated(conn, args)
            _ ->
                create_anonymous(conn, args)
        end
    end

    def create_anonymous(conn, alert_params) do
    end


    def create_authenticated(conn, alert_params) do
    end

end

defmodule SignalNuisance.Reporting do
    import Ecto.Query
    alias SignalNuisance.Repo

    alias SignalNuisance.Reporting.Authorization.{AlertPermission}

    alias SignalNuisance.Reporting.AlertNotifier
    alias SignalNuisance.Reporting.{Alert, AlertType, AlertTypeTranslation}
    alias SignalNuisance.Reporting.AlertBinding
    alias SignalNuisance.Reporting.AlertDispatcher

    def create_alert_type(attrs) do
        AlertType.create(attrs)
    end

    def create_alert_type_translation(attrs) do
        AlertTypeTranslation.create(attrs)
    end

    def alert_type_creation_changeset(alert_type, attrs \\ %{}) do
        AlertType.creation_changeset(alert_type, attrs)
    end

    def change_alert_type(alert_type, attrs \\ %{}) do
        AlertType.update_changeset(alert_type, attrs)
    end

    def update_alert_type(alert_type, attrs \\ %{}) do
        alert_type
        |> change_alert_type(attrs)
        |> Repo.update
    end

    def get_alert_type!(id) do
        Repo.get!(AlertType, id)
    end

    def delete_alert_type(alert_type) do
        Repo.delete(alert_type)
    end

    def paginate_alert_types(params) do
        from(at in AlertType)
        |> Repo.paginate(params)
    end

    def get_alert_types_by_category(category) do
        AlertType.get_by_category(category)
    end

    def get_alert_types_by_category(category, lang) do
        AlertType.get_by_category(category, lang)
    end

    def create_alert(attrs, %SignalNuisance.Accounts.User{} = user) do
        Repo.transaction fn ->
            with {:ok, alert} <- Alert.create(attrs),
                :ok <- AlertBinding.bind_to_user(alert, user),
                :ok <- AlertDispatcher.dispatch(alert)
            do
                alert
            end
        end
    end

    def alert_creation_changeset(alert = %Alert{}, attrs \\ %{}) do
        Alert.creation_changeset(alert, attrs)
    end

    @doc """
    """
    def create_alert(attr) do
        Alert.create(attr)
    end

    def get_alert!(id) do
        with {:ok, report} <- Repo.get(Alert, id: id)
        do
            {:ok, report}
        end
    end
end

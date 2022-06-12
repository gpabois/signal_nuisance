defmodule SignalNuisance.Reporting do
    import Ecto.Query
    alias SignalNuisance.Repo

    alias SignalNuisance.Reporting.Authorization.{AlertPermission}

    alias SignalNuisance.Reporting.AlertNotifier
    alias SignalNuisance.Reporting.{Alert, AlertType, AlertTypeTranslation}
    alias SignalNuisance.Reporting.AlertBinding

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

    def get_alert_type!(id) do
        Repo.get!(AlertType, id)
    end

    def create_alert_by_email(attrs, recipient) do
        case SignalNuisance.Accounts.get_user_by_email(recipient) do
            nil ->
                Repo.transaction fn ->
                    with {:ok, alert} <- Alert.create(attrs),
                        {:ok, token} <- AlertPermission.grant(
                            {:email, recipient},
                            AlertPermission.by_role(:owner),
                            alert
                        ),
                        :ok <- AlertBinding.bind_to_email(alert, recipient),
                        {:ok, _mail} <- AlertNotifier.deliver_token_based_receipt(recipient, alert, token)
                    do
                        {:ok, :alert, [token: token]}
                    else
                        {:error, error} -> Repo.rollback(error)
                    end
                end
            user -> create_alert_by_user(attrs, user)
        end
    end

    def create_alert_by_user(attrs, user) do
        Repo.transaction fn ->
            with {:ok, alert} <- Alert.create(attrs),
                :ok <- AlertBinding.bind_to_user(alert, user),
                :ok <- AlertPermission.grant(
                    user,
                    AlertPermission.by_role(:owner),
                    alert
                ),
                {:ok, _mail} <- AlertNotifier.deliver_user_based_receipt(user, alert)
            do
                {:ok, :alert, []}
            else
                {:error, error} -> Repo.rollback(error)
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

    def get_alert_by_id(id) do
        with {:ok, report} <- Repo.get(Alert, id: id)
        do
            {:ok, report}
        end
    end
end

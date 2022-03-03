defmodule SignalNuisance.Reporting do
    alias SignalNuisance.Repo

    alias SignalNuisance.Reporting.Authorization.{AlertPermission}

    alias SignalNuisance.Reporting.AlertNotifier
    alias SignalNuisance.Reporting.Alert
    alias SignalNuisance.Reporting.AlertBinding

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
                        :ok  <- AlertBinding.bind_to_email(alert, recipient),
                        {:ok, _mail} <- AlertNotifier.deliver_secret_key_based_receipt(recipient, alert, token)
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
                {:ok, _mail}      <- AlertNotifier.deliver_user_based_receipt(user, alert)
            do
                {:ok, :alert, []}
            else
                {:error, error} -> Repo.rollback(error)
            end
        end
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

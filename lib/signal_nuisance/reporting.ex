defmodule SignalNuisance.Reporting do
    alias SignalNuisance.Repo

    alias SignalNuisance.Reporting.Authorization.Permission

    alias SignalNuisance.Reporting.AlertNotifier
    alias SignalNuisance.Reporting.Alert
    alias SignalNuisance.Reporting.AlertBinding

    def create_alert_by_email(attrs, recipient) do
        case SignalNuisance.Accounts.get_user_by_email(recipient) do
            nil ->
                Repo.transaction fn ->
                    with {:ok, alert} <- Alert.create(attrs),
                         {:ok, token} <- Permission.grant(
                             entity:   [email: recipient],
                             resource: [alert: alert],
                             role: :owner
                         ),
                         :ok  <- AlertBiding.bind_to_email(alert, recipient),
                         {:ok, _mail} <- AlertNotifier.deliver_secret_key_based_receipt(recipient, alert, token)
                    do
                        {:ok, :reporting, [token: token]}
                    else
                        {:error, error} -> Repo.rollback(error)
                    end
                end
            user -> create_alert_by_user(attrs, user)
        end
    end

    def create_alert_by_user(attrs, user) do
        Repo.transaction fn ->
            with {:ok, report}     <- Alert.create(attrs),
                 :ok               <- AlertBinding.bind_to_user(report, user),
                 :ok               <- Permission.grant(entity: [user: user], resource: [report: report], role: :owner),
                 {:ok, _mail}      <- AlertNotifier.deliver_user_based_receipt(user, report)
            do
                {:ok, :report, []}
            else
                {:error, error} -> Repo.rollback(error)
            end
        end
    end

    @doc """
        create_alert attr, by: [email: email]
        create_alert attr, by: [user: user]
    """
    def create_alert(attr, opts \\ []) do
        Alert.create(attr)
    end

    def get_alert_by_id(id, opts \\ []) do
        with {:ok, report} <- Report.get(id: id)
        do
            {:ok, report}
        end
    end
end

defmodule SignalNuisance.Reporting do 
    use SignalNuisance.Guard 

    alias SignalNuisance.Repo
    
    alias SignalNuisance.Reporting.Authorization.ReportSecretKeyPermission
    alias SignalNuisance.Reporting.Authorization.ReportUserPermission
    alias SignalNuisance.Reporting.Authorization.ReportPermission   

    alias SignalNuisance.Reporting.ReportingNotifier 
    alias SignalNuisance.Reporting.Report 

    def create_reporting_by_email(attrs, recipient) do
        Repo.transaction fn -> 
            with {:ok, report}     <- Report.create(attrs),
                 {:ok, secret_key} <- ReportSecretKeyPermission.grant(report, ReportPermission.owner_permissions()),
                 {:ok, _mail}      <- ReportingNotifier.deliver_secret_key_based_receipt(recipient, report, secret_key)
            do
                {:ok, :reporting, [secret_key: secret_key]}
            else
                {:error, error} -> Repo.rollback(error)
            end
        end
    end

    def create_reporting_by_user(attrs, user) do
        Repo.transaction fn -> 
            with {:ok, report}     <- Report.create(attrs),
                 :ok <- ReportUserPermission.grant(user, report, ReportPermission.owner_permissions()),
                 {:ok, _mail}      <- ReportingNotifier.deliver_user_based_receipt(user, report)
            do
                {:ok, :report, []}
            else
                {:error, error} -> Repo.rollback(error)
            end
        end
    end

    @doc """
        create_reporting attr, by: [email: email]
        create_reporting attr, by: [user: user]
    """
    def create_reporting(attr, opts \\ []) do
        case Keyword.fetch(opts, :by) do
            {:ok, [{:email, email}]} -> create_reporting_by_email(attr, email)
            {:ok, [{:user, user}]}   -> create_reporting_by_user(attr, user)
            _ -> Report.create(attr)
        end
    end

    def get_by_id(id, opts \\ []) do
        with {:ok, report} <- Report.get(id: id),
             :ok <- is_possible(opts, report: report) 
        do
            {:ok, report}
        end
    end
end
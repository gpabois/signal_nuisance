defmodule SignalNuisance.Reporting.AlertBinding do
    alias SignalNuisance.Repo

    @doc """
        Bind an alert to a user.

        ## Examples
        add alert, user
    """
    def bind_to_user(alert, user) do
        SignalNuisance.Reporting.AlertUserBinding.bind(alert, user)
    end

    @doc """
        Bind an alert to a user.

        ## Examples
        add alert, user
    """
    def bind_to_email(alert, email) do
        SignalNuisance.Reporting.AlertEmailBinding.bind(alert, email)
    end

    @doc """
        Unbind an alert from a user.

        ## Examples
        Remove
    """
    def unbind_from_user(alert, user) do
        SignalNuisance.Reporting.AlertUserBinding.unbind(alert, user)
    end

    @doc """
        Unbind an alert from an email.

        ## Examples
        Remove
    """
    def unbind_from_email(alert, email) do
        SignalNuisance.Reporting.AlertEmailBinding.unbind(alert, email)
    end

    @doc """
        Transfer alerts initially created only with an email, to the account bound to the email.

        User have the possibility to alert, and keep tracks by email only. If he decides to register,
        this function will transfer the previous alerts to its account.
    """
    def transfer_to_user(user) do
        stored = Repo.all(SignalNuisance.Reporting.AlertEmailMember, email: user.email)

        Repo.transaction fn ->
            stored
            |> Enum.each(fn m ->
                bind_to_user %{id: m.alert_id}, user
                unbind_from_email  %{id: m.alert_id}, user.email
            end)
        end

        :ok
    end
end

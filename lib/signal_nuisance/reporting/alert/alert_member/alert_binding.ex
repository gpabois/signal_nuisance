defmodule SignalNuisance.Reporting.AlertBinding do
    alias SignalNuisance.Repo

    @doc false
    defp dispatch(opts) do
        cond do
            Keyword.has_key?(opts, :email) ->
                {SignalNuisance.Reporting.AlertEmailBinding, Keyword.fetch!(opts, :email)
            Keyword.has_key?(opts, :user) ->
                {SignalNuisance.Reporting.AlertEmailBinding, Keyword.fetch!(opts, :user)
            true -> raise "Options are user or email"
        end
        case entity do
            entity when is_string(entity)   -> SignalNuisance.Reporting.AlertEmailBinding
            %SignalNuisance.Accounts.User{} -> SignalNuisance.Reporting.AlertUserBinding
            _                               -> raise "Unknown entity"
        end
    end

    @doc """
        Bind an alert to a user account, or an email.

        ## Examples
        add alert, user: user
        add alert, email: email
    """
    def bind(alert, opts) do
        {hdlr, entity} = dispatch(opts)
        hdlr.add(alert, entity)
    end    

    @doc """
        Unbind an alert from a user account, or an email.

        ## Examples
        Remove 
    """
    def unbind(alert, opts) do
        {hdlr, entity} = dispatch(opts)
        hdlr.remove(alert, entity)
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
                bind    %{id: m.alert_id}, user: user
                unbind  %{id: m.alert_id}, email: email
            end)
        end

        :ok
    end
end
defmodule SignalNuisance.Reporting.AlertEmailBinding do
    use Ecto.Schema

    import Ecto.Changeset
    # import Ecto.Query
    # import Geo.PostGIS

    alias SignalNuisance.Repo
    alias SignalNuisance.Reporting.Alert
    alias SignalNuisance.Accounts.User

    schema "alert_email_bindings" do
      field :email, :string
      belongs_to :alert, Alert
    end

    def bind(alert, entity) do

    end

    def unbind(alert, entity) do

    end
end

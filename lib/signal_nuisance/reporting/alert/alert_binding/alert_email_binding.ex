defmodule SignalNuisance.Reporting.AlertEmailBinding do
    use Ecto.Schema

    import Ecto.Query

    alias SignalNuisance.Repo
    alias SignalNuisance.Reporting.Alert

    schema "alert_email_bindings" do
      field :email, :string
      belongs_to :alert, Alert
    end

    def bind(alert, email) do
      %__MODULE__{
        email: email,
        alert_id: alert.id
      } |> Repo.insert()
    end

    def unbind(alert, email) do
      from(
        b in __MODULE__,
        where: b.email == ^email,
        where: b.alert_id == ^alert.id
      ) |> Repo.delete_all()
    end
end

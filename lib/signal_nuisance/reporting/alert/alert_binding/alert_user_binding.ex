defmodule SignalNuisance.Reporting.AlertUserBinding do
    use Ecto.Schema

    import Ecto.Query

    alias SignalNuisance.Repo
    alias SignalNuisance.Reporting.Alert
    alias SignalNuisance.Accounts.User

    schema "alert_user_bindings" do
      belongs_to :user,  User
      belongs_to :alert, Alert
    end

    def bind(alert, user) do
      %__MODULE__{
        user_id: user.id,
        alert_id: alert.id
      } |> Repo.insert()

    end

    def unbind(alert, user) do
      from(
        b in __MODULE__,
        where: b.user_id == ^user.id,
        where: b.alert_id == ^alert.id
      ) |> Repo.delete_all()
    end
end

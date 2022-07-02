defmodule SignalNuisance.Reporting.AlertDispatcher do
  use Oban.Worker, queue: :events

  alias SignalNuisance.Reporting
  alias SignalNuisance.Facilities

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"alert_id" => id} = args}) do
    alert = Reporting.get_alert!(id)
    Facilities.dispatch_alert(alert)
  end

  def dispatch(alert) do
    %{"alert_id" => alert.id}
    |> new()
    |> Oban.insert()
  end
end

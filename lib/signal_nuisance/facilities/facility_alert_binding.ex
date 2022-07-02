defmodule SignalNuisance.Facilities.FacilityAlertBinding do
  use Ecto.Schema
  import Ecto.Changeset

  schema "facility_alerts_bindings" do

    field :facility_id, :id
    field :alert_id, :id

    timestamps()
  end

  @doc false
  def changeset(facility_alert_binding, attrs) do
    facility_alert_binding
    |> cast(attrs, [:facility_id, :alert_id])
    |> validate_required([:facility_id, :alert_id])
  end
end

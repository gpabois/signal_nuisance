defmodule SignalNuisance.Repo.Migrations.CreateFacilityAlertsBindings do
  use Ecto.Migration

  def change do
    create table(:facility_alerts_bindings) do
      add :facility_id, references(:facilities, on_delete: :nothing)
      add :alert_id, references(:alerts, on_delete: :nothing)

      timestamps()
    end

    create index(:facility_alerts_bindings, [:facility_id])
    create index(:facility_alerts_bindings, [:alert_id])
  end
end

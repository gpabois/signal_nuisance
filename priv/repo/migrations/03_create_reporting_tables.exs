defmodule SignalNuisance.Repo.Migrations.CreateReportingTables do
    use Ecto.Migration

    def up do
        # Assert postgis
        execute "CREATE EXTENSION IF NOT EXISTS postgis;"

        create table(:reports) do
            add :nature, :string, null: false
            add :loc, :geography, null: false
            add :closed, :boolean, default: false
            add :closure_reason, :string
            
            timestamps()
        end

        execute("CREATE INDEX report_loc_idx ON reports USING GIST (loc);")
        
        create table(:reporting_user_permissions) do
            add :report_id, references("reports", on_delete: :delete_all), null: false
            add :user_id, references("reports", on_delete: :delete_all), null: false
            add :permissions, :integer, null: false
        end

        create unique_index(:reporting_user_permissions, [:report_id, :user_id], name: :report_user_permissions_unique_index)
    end
end
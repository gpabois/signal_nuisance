defmodule SignalNuisance.Repo.Migrations.CreateReportingTables do
    use Ecto.Migration

    def up do
        # Assert postgis
        execute "CREATE EXTENSION IF NOT EXISTS postgis;"

        create table(:alerts) do
            add :nature, :string, null: false
            add :loc,    :geography, null: false
            add :closed, :boolean, default: false

            timestamps()
        end

        execute("CREATE INDEX alert_loc_idx ON alerts USING GIST (loc);")

        create table(:alert_user_bindings) do
            add :alert_id, references("alerts", on_delete: :delete_all), null: false
            add :user_id, references("users", on_delete: :delete_all), null: false
        end

        create unique_index(:alert_user_bindings, [:alert_id, :user_id], name: :alert_user_bindings_unique_index)

        create table(:alert_email_bindings) do
            add :alert_id, references("alerts", on_delete: :delete_all), null: false
            add :email, :citext, null: false
        end

        create unique_index(:alert_email_bindings, [:alert_id, :email], name: :alert_email_bindings_unique_index)

        create table(:alert_user_permissions) do
            add :alert_id, references("alerts", on_delete: :delete_all), null: false
            add :user_id, references("users", on_delete: :delete_all), null: false
            add :permissions, :integer, null: false
        end

        create unique_index(:alert_user_permissions, [:alert_id, :user_id], name: :alert_user_permissions_unique_index)

        create table(:alert_token_permissions) do
            add :alert_id, references("alerts", on_delete: :delete_all), null: false
            add :secret_key, :string, null: false
            add :permissions, :integer, null: false
        end

    end
end

defmodule SignalNuisance.Repo.Migrations.CreateEnterpriseTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS postgis"
    create table(:facilities) do
      add :name, :string
      add :loc, :geography
      add :address, :string
      add :description, :string
      add :valid, :boolean
      timestamps()
    end
    
    create unique_index(:facilities, [:name], name: :facility_name_unique_index)

    execute("CREATE INDEX facility_loc_idx ON facilities USING GIST (loc);")

    create table (:facility_members) do
      add :facility_id, references(:facilities, on_delete: :delete_all), null: false
      add :user_id, references(:users), null: false
    end

    create unique_index(:facility_members, [:facility_id, :user_id], name: :facility_members_unique_index)
    
    create table (:facility_user_permissions) do
      add :facility_id, references(:facilities, on_delete: :delete_all), null: false
      add :user_id,       references(:users, on_delete: :delete_all), null: false
      add :permissions,   :integer, null: false
    end

    create unique_index(:facility_user_permissions, [:facility_id, :user_id], name: :facility_user_permissions_unique_index)
  end
end

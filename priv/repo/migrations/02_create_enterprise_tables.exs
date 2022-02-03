defmodule SignalNuisance.Repo.Migrations.CreateEnterpriseTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS postgis"

    create table(:enterprises) do
      add :name, :string
      add :slug, :string

      timestamps()
    end

    create unique_index(:enterprises, [:slug], name: :enterprise_slug_unique_index)
    create unique_index(:enterprises, [:name], name: :enterprise_name_unique_index)

    create table(:establishments) do
      add :enterprise_id, references(:enterprises, on_delete: :delete_all), null: false

      add :name, :string
      add :slug, :string
      add :loc, :geography

      timestamps()
    end
    
    execute("CREATE INDEX establishment_loc_idx ON establishments USING GIST (loc);")

    create unique_index(:establishments, [:slug], name: :establishment_slug_unique_index)
    create unique_index(:establishments, [:name, :enterprise_id], name: :establishment_name_enterprise_unique_index)

    create table (:enterprise_members) do
      add :enterprise_id, references(:enterprises, on_delete: :delete_all), null: false
      add :user_id, references(:users), null: false
    end

    create unique_index(:enterprise_members, [:enterprise_id, :user_id], name: :enterprise_members_unique_index)
    
    create table (:enterprise_user_permissions) do
      add :enterprise_id, references("enterprises", on_delete: :delete_all), null: false
      add :user_id,       references("users", on_delete: :delete_all), null: false
      add :permissions,   :integer, null: false
    end

    create unique_index(:enterprise_user_permissions, [:enterprise_id, :user_id], name: :enterprise_user_permissions_unique_index)

    create table (:establishment_user_permissions) do
      add :establishment_id, references("establishments", on_delete: :delete_all), null: false
      add :user_id,          references("users", on_delete: :delete_all), null: false
      add :permissions,      :integer, null: false
    end

    create unique_index(:establishment_user_permissions, [:establishment_id, :user_id], name: :establishment_user_permissions_unique_index)

  end
end

defmodule SignalNuisance.Repo.Migrations.CreateEnterprises do
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
      add :enterprise_id, references(:enterprises), null: false

      add :name, :string
      add :slug, :string
      add :loc, :geography
    end
    
    execute("CREATE INDEX establishment_loc_idx ON establishments USING GIST (loc);")

    create unique_index(:establishments, [:slug], name: :establishment_slug_unique_index)
    create unique_index(:establishments, [:name, :enterprise_id], name: :establishment_name_enterprise_unique_index)

    create table (:enterprise_members) do
      add :enterprise_id, references(:enterprises), null: false
      add :user_id, references(:users), null: false
    end

    create unique_index(:enterprise_members, [:enterprise_id, :user_id], name: :enterprise_member_user_enterprise_unique_index)

  end
end

defmodule SignalNuisance.Repo.Migrations.CreateAdministrationTables do
  use Ecto.Migration

  def change do
    create table (:administration_user_permissions) do
      add :user_id,       references("users", on_delete: :delete_all), null: false
      add :permissions,   :integer, null: false
    end

    create unique_index(:administration_user_permissions, [:user_id], name: :administration_user_permissions_unique_index)

    create table (:administrators) do
      add :user_id, references(:users), null: false
    end

    create unique_index(:administrators, [:user_id], name: :administrators_unique_index)

  end
end

defmodule SignalNuisance.Reporting.Authorization.AlertTokenPermission do
    alias SignalNuisance.Reporting.Authorization.AlertPermission, as: Permission

    use SignalNuisance.Authorization.Permission,
        permissions: Permission.permissions()
        encoding: :byte

    use Ecto.Schema

    alias SignalNuisance.Repo
    alias SignalNuisance.Reporting.Alert

    import Ecto.Query
    import Ecto.Changeset

    schema "alert_token_permissions" do
        belongs_to :alert,  Alert
        field :secret_key,  :string
        field :permissions, :integer
    end

    def grant(context) do
        secret_key = :crypto.strong_rand_bytes(10)
        permissions = context |> get_permissions() |> encode_permission()
        alert = context |> get_resource!(:alert)
        
        with {:ok, perm} <- %__MODULE__{
           alert_id:alert.id, 
            secret_key: secret_key, 
            permissions: permissions
        }|> Repo.insert 
        do
            {:ok, perm.secret_key}
        end
    end

    def alter(context) do
        permissions = context |> get_permissions() |> encode_permission()
        secret_key = context |> get_entity!(:token)

        Repo.get_by(__MODULE__, secret_key: secret_key)
        |> change(%{permissions: permissions})
        |> Repo.update
    end

    def revoke_all(context) do
        secret_key = context |> get_entity!(:token)

        from(
            perm in __MODULE__,
            where: perm.secret_key == ^secret_key
        ) |> Repo.delete_all

        :ok
    end

    def revoke(context) do
        secret_key = context |> get_entity!(:token)
        from(
            perm in __MODULE__,
            where: perm.secret_key == ^secret_key
        ) |> Repo.delete_all
        :ok
    end

    def has?(context) do
        permissions = context |> get_permissions() |> encode_permission()
        %{id: alert_id} = context |> get_resource!(:alert)
        token = context |> get_entity!(:token)

        from(perm in __MODULE__,
            where: perm.secret_key == ^secret_key,
            where: perm.alert_id == ^alert_id,
            select: perm.permissions
        ) |> Repo.any(fn p -> (p &&& permissions) == permissions end)
    end
end
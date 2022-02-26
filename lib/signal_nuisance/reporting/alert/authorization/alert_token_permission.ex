defmodule SignalNuisance.Reporting.Authorization.AlertTokenPermission do
    alias SignalNuisance.Reporting.Authorization.AlertPermission, as: Permission

    use SignalNuisance.Authorization.Permission,
        permissions: Permission.permissions(),
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

    def grant({:token, nil}, permissions, alert) do
        secret_key = :crypto.strong_rand_bytes(10)
        permissions = permissions |> encode_permission()

        with {:ok, perm} <- %__MODULE__{
            alert_id: alert.id,
            secret_key: secret_key,
            permissions: permissions
        }|> Repo.insert
        do
            {:ok, perm.secret_key}
        end
    end

    def revoke_all({:token, secret_key}, _context) do
        from(
            perm in __MODULE__,
            where: perm.secret_key == ^secret_key
        ) |> Repo.delete_all

        :ok
    end

    def revoke({:token, secret_key}, _permissions, _context) do
        from(
            perm in __MODULE__,
            where: perm.secret_key == ^secret_key
        ) |> Repo.delete_all
        :ok
    end

    def has?({:token, secret_key}, permissions, alert) do
        permissions = permissions |> encode_permission()
        %{id: alert_id} = alert

        from(perm in __MODULE__,
            where: perm.secret_key == ^secret_key,
            where: perm.alert_id == ^alert_id,
            select: perm.permissions
        ) |> Repo.all() |> Enum.any(fn x -> is_permission?(x, permissions) end)
    end
end

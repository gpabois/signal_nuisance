defmodule SignalNuisance.Enterprises do
  alias SignalNuisance.Repo

  alias SignalNuisance.Enterprises.Authorization.{EnterprisePermission, EstablishmentPermission}
  alias SignalNuisance.Enterprises.{Enterprise, Establishment, EnterpriseMember}

  def get_enterprise_by_id(id) do
    Enterprise.get_by_id(id)
  end

  @doc """
    Get an enterprise by its name

    Return nil if no enterprise was found
  """
  def get_enterprise_by_name(name) do
    SignalNuisance.Enterprises.Enterprise.get_by_name(name)
  end

  def get_enterprise_by_slug(slug) do
    SignalNuisance.Enterprises.Enterprise.get_by_slug(slug)
  end

  @doc """
    Get enterprise by its member
  """
  def get_enterprise_by_member(user) do
    SignalNuisance.Enterprises.Enterprise.get_by_member(user)
  end

  def enterprise_registration_changeset(enterprise = %Enterprise{}, attrs = %{}) do
    Enterprise.registration_changeset(enterprise, attrs)
  end

  @doc """
    Register an enterprise, and add the user as its member, and grants him owner-related permissions
  """
  def register_enterprise(attrs, %SignalNuisance.Accounts.User{} = user) do
    Repo.transaction fn ->
      with {:ok, enterprise} <- Enterprise.register(attrs),
           :ok <- add_enterprise_member(enterprise, user),
           :ok <- EnterprisePermission.grant(user, EnterprisePermission.by_role(:administrator), enterprise)
      do
        enterprise
      else
        {:error, error} -> Repo.rollback(error)
      end
    end
  end

  def establishment_registration_changeset(establishment = %Establishment{}, attrs = %{}) do
    Establishment.registration_changeset(establishment, attrs)
  end


  @doc """
    Register an establishment, and add the user, and grants him owner-related permissions
  """
  def register_establishment(attrs, %SignalNuisance.Accounts.User{} = user) do
    Repo.transaction fn ->
      with {:ok, establishment} <- Establishment.register(attrs),
           :ok <- set_permissions(user, EstablishmentPermission.by_role(:administrator), establishment)
      do
        establishment
      else
        {:error, error} -> Repo.rollback(error)
      end
    end
  end

  def get_nearest_establishments(%Geo.Point{} = point, %GeoMath.Distance{} = distance) do
    Establishment.get_nearest(point, distance)
  end

  def get_establishments_in_area(%Geo.Point{} = lower_left, %Geo.Point{} = upper_right) do
    Establishment.get_in_area(lower_left, upper_right)
  end

  def get_establishment_by_slug(slug) do
    Establishment.get_by_slug(slug)
  end

  def get_establishments_by_enterprise(enterprise) do
    Establishment.get_by_enterprise(enterprise)
  end

  @doc """
    Add a member in the enterprise

    add_enterprise_member enterprise, user
  """
  def add_enterprise_member(enterprise, user) do
    case Repo.transaction(fn ->
      with :ok <- EnterpriseMember.add(enterprise, user),
           :ok <- EnterprisePermission.grant(
              user,
              EnterprisePermission.by_role(:employee),
              enterprise
            )
      do

      else
        {:error, error} -> Repo.rollback(error)
      end
    end) do
      {:ok, nil} -> :ok
      other -> other
    end
  end

  @doc """
    Remove a member from the enterprise, and revoke its credentials (enterprise-related and establishments-related)

    remove_enterprise_member enterprise, user
  """
  def remove_enterprise_member(enterprise, user) do
    case Repo.transaction(fn ->
      with  :ok <- EnterpriseMember.remove(enterprise, user),
            :ok <- EnterprisePermission.revoke_all(
              user,
              enterprise
            ),
            :ok <- EstablishmentPermission.revoke_all(
              user,
              by: [enterprise: enterprise]
            )
        do

        else
          {:error, error} -> Repo.rollback(error)
        end
    end) do
      {:ok, nil} -> :ok
      other -> other
    end
  end

  @doc """
    Returns the list of an enterprise's members
  """
  def get_enterprise_members(enterprise) do
    enterprise
    |> EnterpriseMember.get_by_enterprise()
    |> Enum.map(fn (m) -> m.user end)
  end

  @doc """
    Checks if the user is a member of an enterprise.

    ## Parameters
    - enterprise
    - user

    ## Examples
    iex> SignalNuisance.Enterprises.is_enterprise_member?(enterprise, user)
  """
  def is_enterprise_member?(enterprise, user) do
    EnterpriseMember.is_member?(enterprise, user)
  end

  @doc """
    Set a entity's enterprise-related permissions

    ## Parameters
      - enterprise: The enterprise
      - user: The user
      - permissions: a permission as planned in SignalNuisance.Enterprises.Authorization.EnterprisePermission.permissions/0
      - opts: Guards (if[...])

    ## Examples
    iex> SignalNuisance.Enterprises.set_user_enterprise_permissions enterprise, user, [{:manage, :members}], if: [is_authorized: initiator, is_not_same: {a, b}]
    iex> SignalNuisance.Enterprises.set_user_enterprise_permissions enterprise, user, [{:manage, :members}]
  """
  def set_permissions(entity, permissions, %SignalNuisance.Enterprises.Enterprise{} = enterprise) do
    EnterprisePermission.grant(
      entity,
      permissions,
      enterprise
    )
  end

  def set_permissions(entity, permissions, %SignalNuisance.Enterprises.Establishment{} = establishment) do
    EstablishmentPermission.grant(
      entity,
      permissions,
      establishment
    )
  end

  @doc """
    Checks if an entity has enterprise-related permissions.

    ## Parameters
    - enterprise
    - entity: {:user, user}, ...
    - permissions: a permission as planned in SignalNuisance.Enterprises.Authorization.EnterprisePermission.permissions/0
  """
  def has_permissions?(entity, permissions, %SignalNuisance.Enterprises.Enterprise{} = enterprise) do
    EnterprisePermission.has?(
      entity,
      permissions,
      enterprise
    )
  end

  def has_permissions?(entity, permissions, %SignalNuisance.Enterprises.Establishment{} = establishment) do
    EstablishmentPermission.has?(
      entity,
      permissions,
      establishment
    )
  end
end

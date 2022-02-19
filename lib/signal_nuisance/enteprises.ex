defmodule SignalNuisance.Enterprises do
  use SignalNuisance.Guard 

  alias SignalNuisance.Repo

  alias SignalNuisance.Authorization.Permission

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

  @doc """
    Get enterprise by its member
  """
  def get_enterprise_by_member(user) do
    SignalNuisance.Enterprises.Enterprise.get_by_member(user)
  end

  @doc """
    Register an enterprise, and add the user as its member, and grants him owner-related permissions
  """
  def register_enterprise(attrs, %SignalNuisance.Accounts.User{} = user) do
    Repo.transaction fn ->
      with {:ok, enterprise} <- Enterprise.create(attrs),
           :ok <- add_enterprise_member(enterprise, user), 
           :ok <- Permission.grant(entity: [user: user], resource: [enterprise: enterprise], role: :administrator)
      do
        enterprise
      else
        {:error, error} -> Repo.rollback(error)
      end
    end
  end

  @doc """
    Register an establishment, and add the user, and grants him owner-related permissions
  """
  def register_establishment(attrs, %SignalNuisance.Accounts.User{} = user, opts \\ []) do
    Repo.transaction fn ->
      with {:ok, enterprise} <- get_enterprise_by_id(attrs.enterprise_id),
           :ok <- is_possible(opts, enterprise: enterprise, manage: :establishments),
           {:ok, establishment} <- Establishment.create(attrs),
           :ok <- set_entity_establishment_permissions(establishment, user, EstablishmentPermission.owner_permission())
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

  def get_establishments_by_enterprise(enterprise) do
    Establishment.get_by_enterprise(enterprise)
  end

  @doc """
    Add a member in the enterprise

    add_enterprise_member enterprise, user, if: [is_authorized: user]
    add_enterprise_member enterprise, user 
  """
  def add_enterprise_member(enterprise, user, opts \\ []) do
    with :ok <- is_possible(opts, enterprise: enterprise, manage: :members) do
      case Repo.transaction(fn ->
        with :ok <- EnterpriseMember.add(enterprise, user),
             :ok <- Permission.grant(
                {:user, user}, 
                resource: [enterprise: enterprise], 
                role: :employee
              )
        do

        else
          {:error, error} -> Repo.rollback(error)
        end
      end) do
        {:ok, _} -> :ok
        error -> error
      end
    end
  end

  @doc """
    Remove a member from the enterprise, and revoke its credentials (enterprise-related and establishments-related)

    remove_enterprise_member enterprise, user, if: [is_authorized: initiator]
    remove_enterprise_member enterprise, user
  """
  def remove_enterprise_member(enterprise, user, opts \\ []) do
    with :ok <- is_possible(opts, enterprise: enterprise, manage: :members) do
      case Repo.transaction(fn ->
      with  :ok <- EnterpriseMember.remove(enterprise, user),
            :ok <- Permission.revoke_all(
              {:user, user}, 
              resource: [enterprise: enterprise]
            ),
            :ok <- Permission.revoke_all(
              {:user, user}, 
              resource: [
                establishment: [
                  by: [enterprise: enterprise]
                ]
              ]
            )
        do

        else
          {:error, error} -> Repo.rollback(error)
        end
      end) do
        {:ok, _} -> :ok
        error -> error
      end
    end
  end

  @doc """
    Returns the list of an enterprise's members

    ## Parameters
    - enterpise
    - opts: Guards (if: [...]), ...

  """
  def get_enterprise_members(enterprise, opts \\ []) do
    with :ok <- is_possible(opts, enterprise: enterprise, manage: :members) do
      enterprise
      |> EnterpriseMember.get_by_enterprise()
      |> Enum.map(fn (m) -> m.user end)
    end
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
  def set_entity_enterprise_permissions(enterprise, user, permissions, guard \\ []) do
    with 
      :ok <- is_possible(
        guard, 
        resource:    [enterprise: enterprise], 
        permissions: [manage: :members]
      )
    do
      Permission.grant(
        user, 
        permissions,
        resource: [enterprise: enterprise]
      )
    end
  end
  
  @doc """
    Checks if an entity has enterprise-related permissions.

    ## Parameters
    - enterprise
    - entity: {:user, user}, ...
    - permissions: a permission as planned in SignalNuisance.Enterprises.Authorization.EnterprisePermission.permissions/0
  """
  def has_entity_enterprise_permission?(enterprise, entity, permissions) do
    Permission.has?(
      entity, 
      permissions,
      resource: [enterprise: enterprise]
    )
  end

  @doc """
    Set a entity's establishment-related permissions

    ## Parameters
    - establishment
    - entity: a user
    
    ## Examples
    iex> SignalNuisance.Enterprises.set_entity_enterprise_permissions enterprise, user, [{:manage, :members}] , if: [is_authorized: initiator, is_not_same: {a, b}]
    iex> SignalNuisance.Enterprises.set_entity_enterprise_permissions enterprise, user, [{:manage, :members}] 
  """
  def set_entity_establishment_permissions(establishment, entity, permissions, opts \\ []) do
    with 
    :ok <- is_possible(
        opts, 
        resource:    [establishment: establishment], 
        permissions: [manage: :members]
      ) 
    do
      Permission.grant(
        entity,
        permissions,
        resource: [establishment: establishment]
      )
    end
  end

  def has_entity_establishment_permission?(establishment, entity, permissions) do
    Permission.has?(
      entity, 
      permissions,
      resource: [establishment: establishment]
    )
  end
  
end

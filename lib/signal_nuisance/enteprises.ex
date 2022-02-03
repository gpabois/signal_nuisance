defmodule SignalNuisance.Enterprises do
  use SignalNuisance.Guard 

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
           :ok <- set_entity_enterprise_permissions(enterprise, user, EnterprisePermission.owner_permission())
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
             :ok <- EnterprisePermission.grant(user, enterprise, EnterprisePermission.base_permission())
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
            :ok <- EnterprisePermission.revoke_all(user, enterprise),
            :ok <- EstablishmentPermission.revoke_all_by_enterprise(user, enterprise)
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
    Get all members of an enterprise
  """
  def get_enterprise_members(enterprise, opts \\ []) do
    with :ok <- is_possible(opts, enterprise: enterprise, manage: :members) do
      enterprise
      |> EnterpriseMember.get_by_enterprise()
      |> Enum.map(fn (m) -> m.user end)
    end
  end

  def is_enterprise_member?(enterprise, user) do
    EnterpriseMember.is_member?(enterprise, user)
  end

  @doc """
    Set a member's permissions in an enterprise

    set_user_enterprise_permissions enterprise, user, [{:manage, :members}] , if: [is_authorized: initiator, is_not_same: {a, b}]
    set_user_enterprise_permissions enterprise, user, [{:manage, :members}] 
  """
  def set_entity_enterprise_permissions(enterprise, user, permissions, opts \\ []) do
    with :ok <- is_possible(opts, enterprise: enterprise, manage: :members) do
      EnterprisePermission.grant(user, enterprise, permissions)
    end
  end
  
  def has_entity_enterprise_permission?(enterprise, user, permissions) do
    EnterprisePermission.has_permission?(user, enterprise, permissions)
  end

  @doc """
    Set an entity (user) permissions in an establishment

    set_entity_enterprise_permissions enterprise, user, [{:manage, :members}] , if: [is_authorized: initiator, is_not_same: {a, b}]
    set_entity_enterprise_permissions enterprise, user, [{:manage, :members}] 
  """
  def set_entity_establishment_permissions(establishment, user, permissions, opts \\ []) do
    with :ok <- is_possible(opts, establishment: establishment, manage: :members) do
      EstablishmentPermission.grant(user, establishment, permissions)
    end
  end

  def has_entity_establishment_permission?(establishment, user, permissions) do
    EstablishmentPermission.has_permission?(user, establishment, permissions)
  end
  
end

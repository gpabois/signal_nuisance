defmodule SignalNuisance.Facilities do
  import Ecto.Query

  alias SignalNuisance.Repo

  alias SignalNuisance.Accounts.User
  alias SignalNuisance.Facilities.Authorization.Permission
  alias SignalNuisance.Facilities.{Facility, FacilityMember}

  def get_by_id(id) do
    Facility.get_by_id(id)
  end


  def get_by_member(user) do
    if user == nil do
      []
    else
      from(
        f in Facility,
        join: m in FacilityMember,
        on: m.facility_id == f.id,
        where: m.user_id == ^user.id
      ) |> Repo.all
    end
  end

  def registration_changeset(facility = %Facility{}, attrs = %{}) do
    Facility.registration_changeset(facility, attrs)
  end

  @doc """
    Register an enterprise, and add the user as its member, and grants him owner-related permissions
  """
  def register(attrs, %User{} = user) do
    Repo.transaction fn ->
      with {:ok, facility} <- Facility.create(attrs),
           :ok <- add_member(facility, user),
           :ok <- Permission.grant(user, Permission.by_role(:administrator), facility)
      do
        facility
      else
        {:error, error} -> Repo.rollback(error)
      end
    end
  end

  def get_nearest_facilities(%Geo.Point{} = point, %GeoMath.Distance{} = distance) do
    Facility.get_nearest(point, distance)
  end

  def get_facilities_in_area(%Geo.Point{} = lower_left, %Geo.Point{} = upper_right) do
    Facility.get_in_area(lower_left, upper_right)
  end

  @doc """
    Add a member to the facility enterprise

    add_member facility, user
  """
  def add_member(facility, user) do
    case Repo.transaction(fn ->
      with :ok <- FacilityMember.add(facility, user),
           :ok <- Permission.grant(
              user,
              Permission.by_role(:employee),
              facility
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
  def remove_member(facility, user) do
    case Repo.transaction(fn ->
      with  :ok <- FacilityMember.remove(facility, user),
            :ok <- Permission.revoke_all(
              user,
              facility
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
  def get_members(facility) do
    facility
    |> FacilityMember.get_by_facility()
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
  def is_member?(facility, user) do
    FacilityMember.is_member?(facility, user)
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
  def set_permissions(entity, permissions, %Facility{} = facility) do
    Permission.grant(
      entity,
      permissions,
      facility
    )
  end

  @doc """
    Checks if an entity has enterprise-related permissions.

    ## Parameters
    - enterprise
    - entity: {:user, user}, ...
    - permissions: a permission as planned in SignalNuisance.Enterprises.Authorization.EnterprisePermission.permissions/0
  """
  def has_permissions?(entity, permissions, %Facility{} = facility) do
    Permission.has?(
      entity,
      permissions,
      facility
    )
  end
end

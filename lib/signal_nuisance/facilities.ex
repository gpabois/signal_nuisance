defmodule SignalNuisance.Facilities do
  import Ecto.Query
  import SignalNuisance.Filter

  alias SignalNuisance.Repo
  alias Phoenix.PubSub

  alias SignalNuisance.Accounts.User
  alias SignalNuisance.Facilities.Authorization.Permission
  alias SignalNuisance.Facilities.{Facility, FacilityMember}

  @doc """
    Create a facilities filter changeset
  """
  def facilities_filter_changeset(data, params \\ %{}) do
    types = %{valid: :boolean}
    {data, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
  end

  @doc """
    Turns the facilities filter changeset into a facilities filter
  """
  def filter_facility(changeset), do: Ecto.Changeset.apply_changes(changeset)

  @doc """
    Paginates facilities
  """
  def paginate_facilities(params, opts \\ []) do
    from(p in Facility)
    |> filter(opts[:filter], Facility)
    |> Repo.paginate(params)
  end

  @doc """
    Get a facility by its id

    raises Ecto.NoResults if no facility exist
  """
  def get_facility!(id), do: Facility.get!(id)

  @doc """
    Deletes a facility
  """
  def delete_facility(facility), do: Repo.delete(facility)

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

  def facility_change(facility, attrs) do
    Facility.update_changeset(facility, attrs)
  end

  def notify_new_alert_to_facility(facility, alert) do
    PubSub.broadcast(SignalNuisance.PubSub, "facility:#{facility.id}", {:new_alert, alert})
  end

  def dispatch_alert(%SignalNuisance.Reporting.Alert{} = alert) do
    Repo.transaction fn ->
      for facility <- Facility.get_at_range(alert.loc) do
        with {:ok, _} <- create_facility_alert_binding(%{facility_id: facility.id, alert_id: alert.id}) do
          notify_new_alert_to_facility(alert, facility)
        end
      end
    end
  end

  def update_facility(facility, attrs) do
    facility
    |> facility_change(attrs)
    |> Repo.update
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

  alias SignalNuisance.Facilities.FacilityAlertBinding

  @doc """
  Returns the list of facility_alerts_bindings.

  ## Examples

      iex> list_facility_alerts_bindings()
      [%FacilityAlertBinding{}, ...]

  """
  def list_facility_alerts_bindings do
    Repo.all(FacilityAlertBinding)
  end

  @doc """
  Gets a single facility_alert_binding.

  Raises `Ecto.NoResultsError` if the Facility alert binding does not exist.

  ## Examples

      iex> get_facility_alert_binding!(123)
      %FacilityAlertBinding{}

      iex> get_facility_alert_binding!(456)
      ** (Ecto.NoResultsError)

  """
  def get_facility_alert_binding!(id), do: Repo.get!(FacilityAlertBinding, id)

  @doc """
  Creates a facility_alert_binding.

  ## Examples

      iex> create_facility_alert_binding(%{field: value})
      {:ok, %FacilityAlertBinding{}}

      iex> create_facility_alert_binding(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_facility_alert_binding(attrs \\ %{}) do
    %FacilityAlertBinding{}
    |> FacilityAlertBinding.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a facility_alert_binding.

  ## Examples

      iex> update_facility_alert_binding(facility_alert_binding, %{field: new_value})
      {:ok, %FacilityAlertBinding{}}

      iex> update_facility_alert_binding(facility_alert_binding, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_facility_alert_binding(%FacilityAlertBinding{} = facility_alert_binding, attrs) do
    facility_alert_binding
    |> FacilityAlertBinding.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a facility_alert_binding.

  ## Examples

      iex> delete_facility_alert_binding(facility_alert_binding)
      {:ok, %FacilityAlertBinding{}}

      iex> delete_facility_alert_binding(facility_alert_binding)
      {:error, %Ecto.Changeset{}}

  """
  def delete_facility_alert_binding(%FacilityAlertBinding{} = facility_alert_binding) do
    Repo.delete(facility_alert_binding)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking facility_alert_binding changes.

  ## Examples

      iex> change_facility_alert_binding(facility_alert_binding)
      %Ecto.Changeset{data: %FacilityAlertBinding{}}

  """
  def change_facility_alert_binding(%FacilityAlertBinding{} = facility_alert_binding, attrs \\ %{}) do
    FacilityAlertBinding.changeset(facility_alert_binding, attrs)
  end
end

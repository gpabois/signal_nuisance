defmodule SignalNuisance.Facilities.FacilityMember do
    use Ecto.Schema

    import Ecto.Query
    import Ecto.Changeset

    alias SignalNuisance.Repo
    alias SignalNuisance.Facilities.Facility
    alias SignalNuisance.Accounts.User

    schema "facility_members" do
      belongs_to :facility, Facility
      belongs_to :user, User
    end

    def registration_changeset(member, attrs) do 
      member
      |> cast(attrs, [:user_id, :facility_id])
      |> foreign_key_constraint(:facility_id, name: :facility_members_facility_id_fkey)
      |> foreign_key_constraint(:user_id, name: :enterprise_members_user_id_fkey)
      |> validate_required([:user_id, :facility_id])
    end
  
    def add(facility, user) do
      with {:ok, _} <- %__MODULE__{}
      |> registration_changeset(%{user_id: user.id, facility_id: facility.id})
      |> Repo.insert 
      do
        :ok
      end
    end

    def remove(facility, user) do
        from(
            m in __MODULE__, 
            where: m.user_id == ^user.id, 
            where: m.facility_id == ^facility.id
        ) |> Repo.delete_all
        :ok
    end

    def is_member?(facility, user) do
      from(
        m in __MODULE__, 
        where: m.facility_id == ^facility.id,
        where: m.user_id == ^user.id
      ) |> Repo.one != nil
    end

    def get_by_facility(facility) do
      from (
        m in __MODULE__,
        where: m.facility_id == ^facility.id
      ) |> Repo.all
    end
  end
  
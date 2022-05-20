
defmodule SignalNuisance.Facilities.Facility do
    use Ecto.Schema

    import Ecto.Changeset
    import Ecto.Query
    import Geo.PostGIS

    alias SignalNuisance.Repo

    schema "facilities" do
      field :name, :string
      field :loc, Geo.PostGIS.Geometry
      field :address, :string
      field :short_description, :string
      field :description, :string
      field :valid, :boolean
      timestamps()
    end

    @doc false
    def registration_changeset(facility, attrs) do
        fields = [:name, :loc]

        facility
        |> cast(attrs, fields)
        |> unique_constraint(:name, name: :facility_name_unique_index)
        |> validate_required(fields)
    end

    @doc """
      Register a facility
    """
    def create(attrs) do
      case attrs do
        {:error, changeset} -> {:error, changeset}
        {:ok, attrs} -> create(attrs)
        attrs -> %__MODULE__{} |> registration_changeset(attrs) |> Repo.insert()
      end

    end

    def get_by_id(id) do
      from(
        e in __MODULE__,
        where: e.id == ^id
      ) |> Repo.one()
    end

    @doc """
      Find all establishments within range
    """
    def get_nearest(%Geo.Point{srid: 4326} = point, %GeoMath.Distance{} = distance) do
      %GeoMath.Distance{value: distance} = GeoMath.Distance.to(distance, :m)

      from(
        ets in __MODULE__,
        where: st_dwithin_in_meters(^point, ets.loc, ^distance)
      ) |> Repo.all
    end


    def get_in_area(%Geo.Point{} = low_left, %Geo.Point{} = up_right) do
      from(
        ets in __MODULE__,
        where: st_within(
          fragment("?::geometry", ets.loc),
          fragment("?::geometry",
            st_set_srid(
              st_make_box_2d(^low_left, ^up_right), 4326)
            )
          )
      ) |> Repo.all
    end
  end

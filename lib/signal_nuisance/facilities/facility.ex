


defmodule SignalNuisance.Facilities.Facility do
    use Ecto.Schema

    import Ecto.Changeset
    import Ecto.Query
    import Geo.PostGIS
    import Slugy

    alias SignalNuisance.Repo
    alias SignalNuisance.Enterprises.Enterprise

    schema "falicities" do
      field :name, :string
      field :loc, Geo.PostGIS.Geometry
      timestamps()
    end

    @doc false
    def registration_changeset(facility, attrs) do
        fields = [:name, :loc]

        establishment
        |> cast(attrs, fields)
        |> validate_required(fields)
    end

    @doc """
      Register an establishment
    """
    def create(attrs) do
      case attrs do
        {:error, changeset} -> {:error, changeset}
        {:ok, %__MODULE__{} = facility} -> Repo.insert(facility)
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

defmodule SignalNuisance.Enterprises.Establishment do
    use Ecto.Schema

    import Ecto.Changeset
    import Ecto.Query
    import Geo.PostGIS
    import Slugy
  
    alias SignalNuisance.Repo
    alias SignalNuisance.Enterprises.Enterprise
  
    schema "establishments" do
      belongs_to :enterprise, Enterprise
      field :name, :string
      field :slug, :string
      field :loc, Geo.PostGIS.Geometry

      timestamps()
    end
  
    @doc false  
    def registration_changeset(establishment, attrs) do 
        fields = [:name, :enterprise_id, :loc]
        
        establishment
        |> cast(attrs, fields)
        |> slugify(with: [:enterprise_id, :name])
        |> unique_constraint(:slug, name: :establishment_slug_unique_index)
        |> validate_required(fields)
    end

    @doc """
      Register an establishment
    """
    def register(attrs) do
      %__MODULE__{}
      |> registration_changeset(attrs)
      |> Repo.insert()
    end

    @doc """
      Find all establishments owned by the enterprise
    """
    def get_by_enterprise(enterprise) do
        from(
            m in __MODULE__, 
            where: m.enterprise_id == ^enterprise.id
        ) |> Repo.all
    end
    
    def get_by_slug(slug) do
      from(
        e in __MODULE__,
        where: e.slug == ^slug
      ) |> Repo.one()
    end

    @doc """
      Find all establishments within range
    """
    def get_nearest(%Geo.Point{} = point, %GeoMath.Distance{} = distance) do
      %GeoMath.Distance{value: distance} = GeoMath.Distance.to(distance, :m)
 
      from(
        ets in __MODULE__,
        where: st_dwithin_in_meters(^point, ets.loc, ^distance)
      ) |> Repo.all
    end


    def get_in_area(%Geo.Point{} = low_left, %Geo.Point{} = up_right) do
      from(
        ets in __MODULE__,
        where: st_within(ets.loc, st_make_box_2d(^low_left, ^up_right))
      )
    end
  end
  
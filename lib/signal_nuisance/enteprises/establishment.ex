defmodule SignalNuisance.Enterprises.Establishment do
    use Ecto.Schema

    import Ecto.Changeset
    import Ecto.Query
    import Geo.PostGIS
  
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
    defp creation_changeset(establishment, attrs) do 
        fields = [:name, :slug, :enterprise_id, :loc]
        
        establishment
        |> cast(attrs, fields)
        |> unique_constraint(:slug, name: :establishment_slug_unique_index)
        |> validate_required(fields)
    end

    @doc """
      Register an establishment
    """
    def create(attrs) do
      %__MODULE__{}
      |> creation_changeset(attrs)
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

  end
  
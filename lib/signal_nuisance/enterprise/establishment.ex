defmodule SignalNuisance.Establishment do
    use Ecto.Schema

    import Ecto.Changeset
    import Ecto.Query
    import Geo.PostGIS
  
    alias SignalNuisance.Repo
    alias SignalNuisance.Enterprise
  
    schema "establishments" do
      belongs_to :enterprise, Enterprise
      field :name, :string
      field :slug, :string
      field :loc, Geo.PostGIS.Geometry
    end
  
    @doc false  
    defp registration_changeset(establishment, attrs) do 
        fields = [:name, :slug, :enterprise_id, :loc]
        
        establishment
        |> cast(attrs, fields)
        |> validate_required(fields)
    end

    @doc """
      Register an establishment
    """
    def register_establishment(attrs) do
      %__MODULE__{}
      |> registration_changeset(attrs)
      |> Repo.insert()
    end

    @doc """
      Find all establishments owned by the enterprise
    """
    def get_by_entreprise(enterprise) do
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
  
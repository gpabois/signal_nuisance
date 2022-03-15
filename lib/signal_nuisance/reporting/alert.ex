defmodule SignalNuisance.Reporting.Alert do
    use Ecto.Schema
    
    import Ecto.Changeset
    # import Ecto.Query
    # import Geo.PostGIS
  
    alias SignalNuisance.Repo
  
    @srid 4326

    schema "alerts" do     
      belongs_to :alert_type, SignalNuisance.Reporting.AlertType
      
      field :loc, Geo.PostGIS.Geometry    
      field :intensity, :integer
      field :closed, :boolean, default: false

      field :loc_long, :float, virtual: true
      field :loc_lat, :float, virtual: true

      timestamps()
    end

    def creation_changeset(%__MODULE__{} = alert, attrs) do
        changeset = alert
        |> cast(attrs, [:alert_type_id, :loc_long, :loc_lat, :intensity, :closed])
        |> validate_required([:alert_type_id, :loc_long, :loc_lat, :intensity, :closed])

        case {fetch_change(changeset, :loc_long), fetch_change(changeset, :loc_lat)} do
            {{:ok, long}, {:ok, lat}} ->
                changeset
                |> put_change(:loc, %Geo.Point{coordinates: {long, lat}, srid: @srid})
            _ -> 
                changeset
        end |> validate_required([:loc])
    
    end

    def create(attr) do
        %__MODULE__{} 
        |> creation_changeset(attr)
        |> Repo.insert()
    end

    def get(opts) do
        case __MODULE__ |> Repo.get(opts) do
            nil -> {:error, :not_found}
            alert -> {:ok, alert}
        end
    end
end
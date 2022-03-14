defmodule SignalNuisance.Reporting.Alert do
    use Ecto.Schema
    
    import Ecto.Changeset
    # import Ecto.Query
    # import Geo.PostGIS
  
    alias SignalNuisance.Repo
  
    schema "alerts" do     
      belongs_to :alert_type, SignalNuisance.Reporting.AlertType
      
      field :loc, Geo.PostGIS.Geometry    
      field :intensity, :integer
      field :closed, :boolean, default: false

      timestamps()
    end

    def creation_changeset(%__MODULE__{} = alert, attrs) do
        alert
        |> cast(attrs, [:alert_type_id, :loc, :intensity, :closed])
        |> validate_required([:alert_type_id, :loc, :intensity, :closed])
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
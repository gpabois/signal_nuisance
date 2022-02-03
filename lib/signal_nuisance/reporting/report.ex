defmodule SignalNuisance.Reporting.Report do
    use Ecto.Schema

    import Ecto.Changeset
    # import Ecto.Query
    # import Geo.PostGIS
  
    alias SignalNuisance.Repo
  
    schema "reports" do
      field :nature, :string

      field :loc, Geo.PostGIS.Geometry
      
      field :closed, :boolean
      field :closure_reason, :string

      timestamps()
    end

    def creation_changeset(signalement, attrs) do
        signalement
        |> cast(attrs, [:nature, :loc])
        |> validate_required([:nature, :loc])
    end

    def create(attr) do
        __MODULE__ 
        |> creation_changeset(attr)
        |> Repo.insert
    end

    def get(opts) do
        case __MODULE__ |> Repo.get(opts) do
            nil -> {:error, :not_found}
            report -> {:ok, report}
        end
    end
end
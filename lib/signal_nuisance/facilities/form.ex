defmodule SignalNuisance.Facilities.FacilityForm do
    use Ecto.Schema
  
    import Ecto.Changeset
  
    embedded_schema do
      field :name, :string
      field :lat, :float
      field :long, :float
    end
  
    @fields [:name, :lat, :long]
  
    def registration_changeset(form, attrs \\ %{}) do
      form 
      |> cast(attrs, @fields)
      |> validate_number(:lat, less_than: 90, greater_than: -90)
      |> validate_number(:long, less_than: 180, greater_than: -180)
  
    end
  
    def to_facility_attributes(changeset) do
        if changeset.valid? do
            %{name: name, lat: lat, long: long} = apply_changes(changeset)
            loc = %Geo.Point{coordinates: {lat, long}, srid: 4326}
            {:ok, %{name: name, loc: loc}}
        else
            {:error, changeset} 
        end
    end
  end
defmodule GeoMath.Distance do
    defstruct [:value, :unit]

    defp to_meter(unit) do
        case unit do
            :km -> 1000.0
            :m -> 1.0
            :dm -> 1.0/10.0
            :cm -> 1.0/100.0
            :mm -> 1.0/1000.0
            _ -> raise "Unknown or unmanaged unit #{unit}"
        end
    end

    defp from_meter(unit) do
        1.0 / to_meter(unit)
    end

    def to(%__MODULE__{value: value, unit: from_unit}, to_unit) do
        %__MODULE__{
            value: value * to_meter(from_unit) * from_meter(to_unit),
            unit: to_unit
        }
    end

    def km(value) do
        %__MODULE__{value: value, unit: :km}
    end

    def m(value) do
        %__MODULE__{value: value, unit: :m}
    end
end

defmodule GeoMath do
    alias GeoMath.Distance

    def distance(%Geo.Point{coordinates: {latA, longA}, srid: srid} , %Geo.Point{coordinates: {latB, longB}}, unit) do
        d = Geocalc.distance_between([latA, longA], [latB, longB])
        %Distance{value: d, unit: :m} |> Distance.to(unit)
    end

    def away_from?(ptA, ptB, %Distance{value: r, unit: unit}, eps \\ 0.01) do
        %Distance{value: d} = distance(ptA, ptB, unit)
        d <= r + eps and d >= r - eps        
    end

    def within?(ptA, ptB, %Distance{value: r, unit: unit}, eps \\ 0.01) do
        %Distance{value: d} = distance(ptA, ptB, unit)
        d <= r + eps
    end

    def random_around(%Geo.Point{coordinates: {lat, long}, srid: srid} = _ptA, %Distance{} = d) do
        %Distance{value: r} = Distance.to(d, :m)

        u = Geocalc.degrees_to_radians(:rand.uniform() * 360.0)
        {:ok, [lat, long]} = Geocalc.destination_point([lat, long], u, r)

        %Geo.Point{
            coordinates: {lat, long},
            srid: srid
        }     
    end

    def random_within(%Geo.Point{coordinates: {lat, long}, srid: srid} = _ptA, %Distance{} = d) do
        %Distance{value: r} = Distance.to(d, :m)

        u = Geocalc.degrees_to_radians(:rand.uniform() * 360.0)
        {:ok, [lat, long]} = Geocalc.destination_point([lat, long], u, r * :rand.uniform())

        %Geo.Point{
            coordinates: {lat, long},
            srid: srid
        }     
    end
end
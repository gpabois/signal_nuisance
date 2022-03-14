defmodule Geo.Fixtures do
    def random_point(srid \\ 4326) do 
        %Geo.Point{coordinates: {48.856614, 2.3522219}, srid: srid}
        |> GeoMath.random_within(GeoMath.Distance.km(500))
    end
end
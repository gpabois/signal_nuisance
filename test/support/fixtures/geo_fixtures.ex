defmodule Geo.Fixtures do
    def random_point(srid \\ 4326), do: %Geo.Point{coordinates: {Faker.Address.latitude(), Faker.Address.longitude()}, srid: srid}
end
Postgrex.Types.define SignalNuisance.PostgresTypes,
    [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
    json: Jason
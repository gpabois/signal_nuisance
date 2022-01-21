defmodule SignalNuisance.Repo do
  use Ecto.Repo,
    otp_app: :signal_nuisance,
    adapter: Ecto.Adapters.Postgres
end

defmodule SignalNuisance.Repo do
  use Ecto.Repo,
    otp_app: :signal_nuisance,
    adapter: Ecto.Adapters.Postgres
    
  use Phoenix.Pagination, per_page: 15

end

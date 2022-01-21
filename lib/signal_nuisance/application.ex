defmodule SignalNuisance.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SignalNuisance.Repo,
      # Start the Telemetry supervisor
      SignalNuisanceWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SignalNuisance.PubSub},
      # Start the Endpoint (http/https)
      SignalNuisanceWeb.Endpoint
      # Start a worker by calling: SignalNuisance.Worker.start_link(arg)
      # {SignalNuisance.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SignalNuisance.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SignalNuisanceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

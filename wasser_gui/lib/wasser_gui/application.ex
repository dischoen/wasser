defmodule WasserGui.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @otp_app :wasser_gui
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      WasserGui.Repo,
      # Start the Telemetry supervisor
      WasserGuiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: WasserGui.PubSub},
      # Start the Endpoint (http/https)
      WasserGuiWeb.Endpoint,
      # Start a worker by calling: WasserGui.Worker.start_link(arg)
      # {WasserGui.Worker, arg}
      PubSub
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WasserGui.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WasserGuiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

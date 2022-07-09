defmodule WasserFirmware.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  #import WasserGui
  
  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WasserFirmware.Supervisor]

    #Application.ensure_all_started :wasser_gui
    
    children =
      Enum.map([], ##channelmap(),
        fn {name, pin} ->
          %{id: name, start: {WasserFirmware.WasserSrv, :start_link, [%{name: name, pin:  pin}]}}
        end)
        ++
      [
        # Children for all targets
        # Starts a worker by calling: WasserFirmware.Worker.start_link(arg)
        # {WasserFirmware.Worker, arg},
        #WasserFirmware.Repo,
        {Task, &HelloSqlite.MigrationHelpers.migrate/0}
       
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: WasserFirmware.Worker.start_link(arg)
      # {WasserFirmware.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: WasserFirmware.Worker.start_link(arg)
      # {WasserFirmware.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:wasser_firmware, :target)
  end
end

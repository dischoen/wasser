import Config

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :shoehorn,
  init: [:nerves_runtime, :nerves_pack],
  app: Mix.Project.config()[:app]

# Nerves Runtime can enumerate hardware devices and send notifications via
# SystemRegistry. This slows down startup and not many programs make use of
# this feature.

config :nerves_runtime, :kernel, use_system_registry: false

# Erlinit can be configured without a rootfs_overlay. See
# https://github.com/nerves-project/erlinit/ for more information on
# configuring erlinit.

config :nerves,
  erlinit: [
    hostname_pattern: "nerves-%s"
  ]

# Configure the device for SSH IEx prompt access and firmware updates
#
# * See https://hexdocs.pm/nerves_ssh/readme.html for general SSH configuration
# * See https://hexdocs.pm/ssh_subsystem_fwup/readme.html for firmware updates

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

# Configure the network using vintage_net
# See https://github.com/nerves-networking/vintage_net for more information
config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"usb0", %{type: VintageNetDirect}},
    {"eth0",
     %{
       type: VintageNetEthernet,
       ipv4: %{method: :dhcp}
     }},
    {"wlan0", %{type: VintageNetWiFi}}
  ]

config :mdns_lite,
  # The `hosts` key specifies what hostnames mdns_lite advertises.  `:hostname`
  # advertises the device's hostname.local. For the official Nerves systems, this
  # is "nerves-<4 digit serial#>.local".  The `"nerves"` host causes mdns_lite
  # to advertise "nerves.local" for convenience. If more than one Nerves device
  # is on the network, it is recommended to delete "nerves" from the list
  # because otherwise any of the devices may respond to nerves.local leading to
  # unpredictable behavior.

  hosts: [:hostname, "wasser"],
  ttl: 120,

  # Advertise the following services over mDNS.
  services: [
    %{
      protocol: "ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "sftp-ssh",
      transport: "tcp",
      port: 22
    },
    %{
      protocol: "epmd",
      transport: "tcp",
      port: 4369
    }
  ]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"
# config :wasser_gui, WasserGuiWeb.Endpoint,
#   url: [host: "wasser.local"],
#   http: [port: 80],
#   cache_static_manifest: "priv/static/cache_manifest.json",
#   secret_key_base: "HEY05EB1dFVSu6KykKHuS4rQPQzSHv4F7mGVB/gnDLrIu75wE/ytBXy2TaL3A6RA",
#   live_view: [signing_salt: "AAAABjEyERMkxgDh"],
#   check_origin: false,
#   # Start the server since we're running in a release instead of through `mix`
#   server: true,
#   render_errors: [view: WasserGuiWeb.ErrorView, accepts: ~w(html json), layout: false],
#   pubsub_server: WasserGui.PubSub,
#   # Nerves root filesystem is read-only, so disable the code reloader
#   code_reloader: false,
#   ecto_repos: [WasserGui.Repo]
# config :wasser_gui, WasserGui.Repo,
#     database: "/data/wasser_firmware/wasser.db",
#     pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

IO.inspect "YO TARGET"

config :wasser_firmware,
  ecto_repos: [WasserFirmware.Repo]

config :wasser_firmware, WasserFirmware.Repo,
  database: "/data/wasser_firmware/wasser.db",
  show_sensitive_data_on_connection_error: false,
  journal_mode: :wal,
  cache_size: -64000,
  temp_store: :memory,
  pool_size: 1

config :nerves_time_zones,
  default_time_zone: "Europe/Vienna"

if System.get_env("PHX_SERVER") do
  config :wasser_gui, WasserGuiWeb.Endpoint, server: true
end

IO.inspect config_env(), label: "config-env"


database_path =
  System.get_env("DATABASE_PATH") ||
  raise """
  environment variable DATABASE_PATH is missing.
  For example: /etc/wasser_gui/wasser_gui.db
  """

IO.inspect database_path, label: "DB PATH"
config :wasser_gui, WasserGui.Repo,
  database: "/data/wasser_firmware/wasser.db",
  #database: database_path,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")


#if config_env() == :prod do
  

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  IO.inspect "I AM IN RUNTIME"
  
  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :wasser_gui, WasserGuiWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    check_origin: ["https://hofmokl.hopto.org",
                  "https://192.168.1.230"],
    secret_key_base: secret_key_base,
    live_view: [signing_salt: "AAAABjEyERMkxgDh"],
    pubsub_server: WasserGui.PubSub,
    code_reloader: false,
    https: [
      ip: {0, 0, 0, 0},
      port: 443,
      cipher_suite: :strong,
      keyfile: System.get_env("WASSER_GUI_SSL_KEY_PATH"),
      certfile: System.get_env("WASSER_GUI_SSL_CERT_PATH")
    ],
    force_ssl: [hsts: true]

#end

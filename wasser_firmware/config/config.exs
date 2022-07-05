# This file is responsible for configuring your application and its
# dependencies.
#
# This configuration file is loaded before any dependency and is restricted to
# this project.
import Config

# Enable the Nerves integration with Mix
Application.start(:nerves_bootstrap)

config :wasser_firmware, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1654925815"

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

if Mix.target() == :host or Mix.target() == :"" do
  import_config "host.exs"
else
  import_config "target.exs"
end

ssid = System.get_env("WLAN_SSID")
psk  = System.get_env("WLAN_PSK")
if ssid == nil or psk == nil do
  raise "WLAN ID not supplied!"
end


config :vintage_net,
  config: [
    {"wlan0", %{type: VintageNetWiFi,
                vintage_net_wifi: %{
                  networks: [
                    %{
                      key_mgmt: :wpa_psk,
                      ssid: ssid,
                      psk:  psk
                    }
                  ]
                },
                ipv4: %{method: :dhcp},
               }
    }
  ]

                
config :phoenix, :json_library, Jason

config :nerves_time, await_initialization_timeout: :timer.seconds(5)
config :nerves_time, :servers, [
  "0.pool.ntp.org",
  "1.pool.ntp.org",
  "2.pool.ntp.org",
  "3.pool.ntp.org"
  ]
# config/config.exs

config :nerves_time,
  earliest_time: ~N[2022-06-06 00:00:00],
  latest_time: ~N[2030-01-01 00:00:00]

import Config

# Add configuration that is only needed when running on the host here.
config :wasser_firmware,
  ecto_repos: [WasserFirmware.Repo]

config :wasser_firmware, WasserFirmware.Repo,
  database: "/tmp/wasser_firmware.db",
  show_sensitive_data_on_connection_error: false,
  journal_mode: :wal,
  cache_size: -64000,
  temp_store: :memory,
  pool_size: 1

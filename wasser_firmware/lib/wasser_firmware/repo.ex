defmodule WasserFirmware.Repo do
  use Ecto.Repo, otp_app: :wasser_firmware, adapter: Ecto.Adapters.SQLite3
end

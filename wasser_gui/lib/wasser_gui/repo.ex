defmodule WasserGui.Repo do
  use Ecto.Repo,
    otp_app: :wasser_gui,
    adapter: Ecto.Adapters.SQLite3
end

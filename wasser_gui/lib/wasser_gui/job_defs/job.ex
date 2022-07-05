defmodule WasserGui.JobDefs.Job do
  use Ecto.Schema
  import Ecto.Changeset

  import WasserGui
  
  schema "jobs" do
    field :duration, :time
    field :on, :time
    field :valve, Ecto.Enum, values: channellist()

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:valve, :on, :duration])
    |> validate_required([:valve, :on, :duration])
  end
end

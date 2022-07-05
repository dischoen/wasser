defmodule WasserGui.Assets.Valve do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assets" do
    field :name, :string
    field :pin, :integer

    timestamps()
  end

  @doc false
  def changeset(valve, attrs) do
    valve
    |> cast(attrs, [:name, :pin])
    |> validate_required([:name, :pin])
  end
end

defmodule WasserGui.Repo.Migrations.CreateAssets do
  use Ecto.Migration

  def change do
    create table(:assets) do
      add :name, :string
      add :pin, :integer

      timestamps()
    end
  end
end

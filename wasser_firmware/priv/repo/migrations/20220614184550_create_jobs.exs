defmodule WasserGui.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :valve, :string
      add :on, :time
      add :duration, :time

      timestamps()
    end
  end
end

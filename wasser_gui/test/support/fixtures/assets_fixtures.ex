defmodule WasserGui.AssetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WasserGui.Assets` context.
  """

  @doc """
  Generate a valve.
  """
  def valve_fixture(attrs \\ %{}) do
    {:ok, valve} =
      attrs
      |> Enum.into(%{
        name: "some name",
        pin: 42
      })
      |> WasserGui.Assets.create_valve()

    valve
  end
end

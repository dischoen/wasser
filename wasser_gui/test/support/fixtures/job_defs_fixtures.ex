defmodule WasserGui.JobDefsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WasserGui.JobDefs` context.
  """

  @doc """
  Generate a job.
  """
  def job_fixture(attrs \\ %{}) do
    {:ok, job} =
      attrs
      |> Enum.into(%{
        duration: ~T[14:00:00],
        on: ~T[14:00:00],
        valve: "some valve"
      })
      |> WasserGui.JobDefs.create_job()

    job
  end
end

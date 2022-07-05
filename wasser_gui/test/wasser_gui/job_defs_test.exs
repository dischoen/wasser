defmodule WasserGui.JobDefsTest do
  use WasserGui.DataCase

  alias WasserGui.JobDefs

  describe "jobs" do
    alias WasserGui.JobDefs.Job

    import WasserGui.JobDefsFixtures

    @invalid_attrs %{duration: nil, on: nil, valve: nil}

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert JobDefs.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert JobDefs.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      valid_attrs = %{duration: ~T[14:00:00], on: ~T[14:00:00], valve: "some valve"}

      assert {:ok, %Job{} = job} = JobDefs.create_job(valid_attrs)
      assert job.duration == ~T[14:00:00]
      assert job.on == ~T[14:00:00]
      assert job.valve == "some valve"
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = JobDefs.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      update_attrs = %{duration: ~T[15:01:01], on: ~T[15:01:01], valve: "some updated valve"}

      assert {:ok, %Job{} = job} = JobDefs.update_job(job, update_attrs)
      assert job.duration == ~T[15:01:01]
      assert job.on == ~T[15:01:01]
      assert job.valve == "some updated valve"
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = JobDefs.update_job(job, @invalid_attrs)
      assert job == JobDefs.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = JobDefs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> JobDefs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = JobDefs.change_job(job)
    end
  end
end

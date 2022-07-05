defmodule WasserGuiWeb.JobLiveTest do
  use WasserGuiWeb.ConnCase

  import Phoenix.LiveViewTest
  import WasserGui.JobDefsFixtures

  @create_attrs %{duration: %{hour: 14, minute: 0}, on: %{hour: 14, minute: 0}, valve: "some valve"}
  @update_attrs %{duration: %{hour: 15, minute: 1}, on: %{hour: 15, minute: 1}, valve: "some updated valve"}
  @invalid_attrs %{duration: %{hour: 14, minute: 0}, on: %{hour: 14, minute: 0}, valve: nil}

  defp create_job(_) do
    job = job_fixture()
    %{job: job}
  end

  describe "Index" do
    setup [:create_job]

    test "lists all jobs", %{conn: conn, job: job} do
      {:ok, _index_live, html} = live(conn, Routes.job_index_path(conn, :index))

      assert html =~ "Listing Jobs"
      assert html =~ job.valve
    end

    test "saves new job", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.job_index_path(conn, :index))

      assert index_live |> element("a", "New Job") |> render_click() =~
               "New Job"

      assert_patch(index_live, Routes.job_index_path(conn, :new))

      assert index_live
             |> form("#job-form", job: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#job-form", job: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.job_index_path(conn, :index))

      assert html =~ "Job created successfully"
      assert html =~ "some valve"
    end

    test "updates job in listing", %{conn: conn, job: job} do
      {:ok, index_live, _html} = live(conn, Routes.job_index_path(conn, :index))

      assert index_live |> element("#job-#{job.id} a", "Edit") |> render_click() =~
               "Edit Job"

      assert_patch(index_live, Routes.job_index_path(conn, :edit, job))

      assert index_live
             |> form("#job-form", job: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#job-form", job: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.job_index_path(conn, :index))

      assert html =~ "Job updated successfully"
      assert html =~ "some updated valve"
    end

    test "deletes job in listing", %{conn: conn, job: job} do
      {:ok, index_live, _html} = live(conn, Routes.job_index_path(conn, :index))

      assert index_live |> element("#job-#{job.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#job-#{job.id}")
    end
  end

  describe "Show" do
    setup [:create_job]

    test "displays job", %{conn: conn, job: job} do
      {:ok, _show_live, html} = live(conn, Routes.job_show_path(conn, :show, job))

      assert html =~ "Show Job"
      assert html =~ job.valve
    end

    test "updates job within modal", %{conn: conn, job: job} do
      {:ok, show_live, _html} = live(conn, Routes.job_show_path(conn, :show, job))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Job"

      assert_patch(show_live, Routes.job_show_path(conn, :edit, job))

      assert show_live
             |> form("#job-form", job: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#job-form", job: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.job_show_path(conn, :show, job))

      assert html =~ "Job updated successfully"
      assert html =~ "some updated valve"
    end
  end
end

defmodule WasserGuiWeb.JobLive.Index do
  use WasserGuiWeb, :live_view

  alias WasserGui.JobDefs
  alias WasserGui.JobDefs.Job

  alias WasserGui.Assets
  alias WasserGui.Assets.Valve

  
  @impl true
  def mount(_params, _session, socket) do
    s2 = assign(socket,
        jobs: list_jobs(),
      assets: list_assets())

    IO.inspect s2
    
    {:ok, s2}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Job")
    |> assign(:job, JobDefs.get_job!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Job")
    |> assign(:job, %Job{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Jobs")
    |> assign(:job, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    job = JobDefs.get_job!(id)
    {:ok, _} = JobDefs.delete_job(job)

    {:noreply, assign(socket, :jobs, list_jobs())}
  end

  defp list_jobs do
    JobDefs.list_jobs()
  end
  defp list_assets do
    Assets.list_assets()
  end
end

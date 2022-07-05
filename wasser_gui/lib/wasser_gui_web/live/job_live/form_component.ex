defmodule WasserGuiWeb.JobLive.FormComponent do
  use WasserGuiWeb, :live_component

  alias WasserGui.JobDefs
  alias WasserGui.Assets

  @impl true
  def update(%{job: job} = assigns, socket) do
    changeset = JobDefs.change_job(job)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"job" => job_params}, socket) do
    changeset =
      socket.assigns.job
      |> JobDefs.change_job(job_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"job" => job_params}, socket) do
    save_job(socket, socket.assigns.action, job_params)
  end

  defp save_job(socket, :edit, job_params) do
    case JobDefs.update_job(socket.assigns.job, job_params) do
      {:ok, _job} ->
        {:noreply,
         socket
         |> put_flash(:info, "Job updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_job(socket, :new, job_params) do
    case JobDefs.create_job(job_params) do
      {:ok, _job} ->
        {:noreply,
         socket
         |> put_flash(:info, "Job created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

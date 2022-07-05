defmodule WasserGuiWeb.ValveLive.FormComponent do
  use WasserGuiWeb, :live_component

  alias WasserGui.Valves

  @impl true
  def update(%{valve: valve} = assigns, socket) do
    changeset = Valves.change_valve(valve)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"valve" => valve_params}, socket) do
    changeset =
      socket.assigns.valve
      |> Valves.change_valve(valve_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

end

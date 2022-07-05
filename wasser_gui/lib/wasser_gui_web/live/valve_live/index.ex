defmodule WasserGuiWeb.ValveLive.Index do
  use WasserGuiWeb, :live_view

  alias WasserGui.Valves
  alias WasserGui.Valves.Valve

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :valves, list_valves())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Valve")
    |> assign(:valve, Valves.get_valve!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Valves")
    |> assign(:valve, nil)
  end

  defp list_valves do
    Valves.list_valves()
  end
end

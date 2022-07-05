defmodule WasserGuiWeb.WasserLive do
  use WasserGuiWeb, :live_view

  import WasserGui
  
  def mount(_params, _session, socket) do
    states = Map.new(WasserGui.channelmap(),
                      fn {k,_v} -> {k, WasserFirmware.WasserSrv.state(k)} end)
    socket = assign(socket, :valves, states)
    {:ok, socket} 
  end

  def render(assigns) do
    ~L"""
    <h1>Valves</h1>
    <table>
    <thead>
    <tr>
    <th></th>
    </tr>
    </thead>
    <tbody id="valves">
      <%= for {k,v} <- @valves do %>
        <tr id="valve-<%= k %>" >
        <td>
          <span>
            <label><%= k %></button>
          </span>
          <span>
            <button disabled><%= v %></button>
          </span>
          <span>
            <button phx-click="on" phx-value-valve="<%= k %>">on</button>
          </span>
          <span>
            <button phx-click="off" phx-value-valve="<%= k %>">off</button>
          </span>
        </td>
        </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
  
  def handle_event("on", %{"valve" => valve}, socket) do
    avalve = String.to_atom valve
    valves = socket.assigns.valves

    WasserFirmware.WasserSrv.on avalve
    newstate = Map.update valves, avalve, 0, fn _i -> "on" end
    
    {:noreply, assign(socket, :valves, newstate) }
  end

  def handle_event("off", %{"valve" => valve}, socket) do
    avalve = String.to_atom valve
    valves = socket.assigns.valves

    WasserFirmware.WasserSrv.off avalve
    newstate = Map.update valves, avalve, 0, fn _i -> "off" end
    
    {:noreply, assign(socket, :valves, newstate) }
  end

end

defmodule WasserGuiWeb.ValveController do
  use WasserGuiWeb, :controller

  alias WasserGui.Assets
  alias WasserGui.Assets.Valve

  def index(conn, _params) do
    assets = Assets.list_assets()
    render(conn, "index.html", assets: assets)
  end

  def new(conn, _params) do
    changeset = Assets.change_valve(%Valve{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"valve" => valve_params}) do
    case Assets.create_valve(valve_params) do
      {:ok, valve} ->
        conn
        |> put_flash(:info, "Valve created successfully.")
        |> redirect(to: Routes.valve_path(conn, :show, valve))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    valve = Assets.get_valve!(id)
    render(conn, "show.html", valve: valve)
  end

  def edit(conn, %{"id" => id}) do
    valve = Assets.get_valve!(id)
    changeset = Assets.change_valve(valve)
    render(conn, "edit.html", valve: valve, changeset: changeset)
  end

  def update(conn, %{"id" => id, "valve" => valve_params}) do
    valve = Assets.get_valve!(id)

    case Assets.update_valve(valve, valve_params) do
      {:ok, valve} ->
        conn
        |> put_flash(:info, "Valve updated successfully.")
        |> redirect(to: Routes.valve_path(conn, :show, valve))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", valve: valve, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    valve = Assets.get_valve!(id)
    {:ok, _valve} = Assets.delete_valve(valve)

    conn
    |> put_flash(:info, "Valve deleted successfully.")
    |> redirect(to: Routes.valve_path(conn, :index))
  end
end

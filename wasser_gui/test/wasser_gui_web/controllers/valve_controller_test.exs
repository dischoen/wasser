defmodule WasserGuiWeb.ValveControllerTest do
  use WasserGuiWeb.ConnCase

  import WasserGui.AssetsFixtures

  @create_attrs %{name: "some name", pin: 42}
  @update_attrs %{name: "some updated name", pin: 43}
  @invalid_attrs %{name: nil, pin: nil}

  describe "index" do
    test "lists all assets", %{conn: conn} do
      conn = get(conn, Routes.valve_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Assets"
    end
  end

  describe "new valve" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.valve_path(conn, :new))
      assert html_response(conn, 200) =~ "New Valve"
    end
  end

  describe "create valve" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.valve_path(conn, :create), valve: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.valve_path(conn, :show, id)

      conn = get(conn, Routes.valve_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Valve"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.valve_path(conn, :create), valve: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Valve"
    end
  end

  describe "edit valve" do
    setup [:create_valve]

    test "renders form for editing chosen valve", %{conn: conn, valve: valve} do
      conn = get(conn, Routes.valve_path(conn, :edit, valve))
      assert html_response(conn, 200) =~ "Edit Valve"
    end
  end

  describe "update valve" do
    setup [:create_valve]

    test "redirects when data is valid", %{conn: conn, valve: valve} do
      conn = put(conn, Routes.valve_path(conn, :update, valve), valve: @update_attrs)
      assert redirected_to(conn) == Routes.valve_path(conn, :show, valve)

      conn = get(conn, Routes.valve_path(conn, :show, valve))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, valve: valve} do
      conn = put(conn, Routes.valve_path(conn, :update, valve), valve: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Valve"
    end
  end

  describe "delete valve" do
    setup [:create_valve]

    test "deletes chosen valve", %{conn: conn, valve: valve} do
      conn = delete(conn, Routes.valve_path(conn, :delete, valve))
      assert redirected_to(conn) == Routes.valve_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.valve_path(conn, :show, valve))
      end
    end
  end

  defp create_valve(_) do
    valve = valve_fixture()
    %{valve: valve}
  end
end

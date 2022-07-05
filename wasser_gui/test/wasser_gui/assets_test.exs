defmodule WasserGui.AssetsTest do
  use WasserGui.DataCase

  alias WasserGui.Assets

  describe "assets" do
    alias WasserGui.Assets.Valve

    import WasserGui.AssetsFixtures

    @invalid_attrs %{name: nil, pin: nil}

    test "list_assets/0 returns all assets" do
      valve = valve_fixture()
      assert Assets.list_assets() == [valve]
    end

    test "get_valve!/1 returns the valve with given id" do
      valve = valve_fixture()
      assert Assets.get_valve!(valve.id) == valve
    end

    test "create_valve/1 with valid data creates a valve" do
      valid_attrs = %{name: "some name", pin: 42}

      assert {:ok, %Valve{} = valve} = Assets.create_valve(valid_attrs)
      assert valve.name == "some name"
      assert valve.pin == 42
    end

    test "create_valve/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Assets.create_valve(@invalid_attrs)
    end

    test "update_valve/2 with valid data updates the valve" do
      valve = valve_fixture()
      update_attrs = %{name: "some updated name", pin: 43}

      assert {:ok, %Valve{} = valve} = Assets.update_valve(valve, update_attrs)
      assert valve.name == "some updated name"
      assert valve.pin == 43
    end

    test "update_valve/2 with invalid data returns error changeset" do
      valve = valve_fixture()
      assert {:error, %Ecto.Changeset{}} = Assets.update_valve(valve, @invalid_attrs)
      assert valve == Assets.get_valve!(valve.id)
    end

    test "delete_valve/1 deletes the valve" do
      valve = valve_fixture()
      assert {:ok, %Valve{}} = Assets.delete_valve(valve)
      assert_raise Ecto.NoResultsError, fn -> Assets.get_valve!(valve.id) end
    end

    test "change_valve/1 returns a valve changeset" do
      valve = valve_fixture()
      assert %Ecto.Changeset{} = Assets.change_valve(valve)
    end
  end
end

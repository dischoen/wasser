defmodule WasserGui.Assets do
  @moduledoc """
  The Assets context.
  """

  import Ecto.Query, warn: false
  alias WasserGui.Repo

  alias WasserGui.Assets.Valve

  @doc """
  Returns the list of assets.

  ## Examples

      iex> list_assets()
      [%Valve{}, ...]

  """
  def list_assets do
    Repo.all(Valve)
  end

  @doc """
  Gets a single valve.

  Raises `Ecto.NoResultsError` if the Valve does not exist.

  ## Examples

      iex> get_valve!(123)
      %Valve{}

      iex> get_valve!(456)
      ** (Ecto.NoResultsError)

  """
  def get_valve!(id), do: Repo.get!(Valve, id)

  @doc """
  Creates a valve.

  ## Examples

      iex> create_valve(%{field: value})
      {:ok, %Valve{}}

      iex> create_valve(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_valve(attrs \\ %{}) do
    %Valve{}
    |> Valve.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a valve.

  ## Examples

      iex> update_valve(valve, %{field: new_value})
      {:ok, %Valve{}}

      iex> update_valve(valve, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_valve(%Valve{} = valve, attrs) do
    valve
    |> Valve.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a valve.

  ## Examples

      iex> delete_valve(valve)
      {:ok, %Valve{}}

      iex> delete_valve(valve)
      {:error, %Ecto.Changeset{}}

  """
  def delete_valve(%Valve{} = valve) do
    Repo.delete(valve)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking valve changes.

  ## Examples

      iex> change_valve(valve)
      %Ecto.Changeset{data: %Valve{}}

  """
  def change_valve(%Valve{} = valve, attrs \\ %{}) do
    Valve.changeset(valve, attrs)
  end
end

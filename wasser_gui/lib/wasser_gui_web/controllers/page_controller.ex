defmodule WasserGuiWeb.PageController do
  use WasserGuiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

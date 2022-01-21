defmodule SignalNuisanceWeb.PageController do
  use SignalNuisanceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

defmodule SignalNuisanceWeb.FallbackController do
  use SignalNuisanceWeb, :controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> put_view(SignalNuisanceWeb.ErrorView)
    |> render(:"403")
  end
end

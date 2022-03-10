defmodule SignalNuisanceWeb.ErrorController do
    use SignalNuisanceWeb, :controller

    def call(conn, {:error, :unauthorized}) do
        conn 
        |> put_view(SignalNuisanceWeb.ErrorView)
        |> put_status(:forbidden) 
        |> render(:"403")
    end
end
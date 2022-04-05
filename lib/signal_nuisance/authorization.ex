defmodule SignalNuisance.Authorization do
    def permit?(policy, action, user, object) do
        Bodyguard.permit?(policy, action, user, object)
    end

    def permit?(policy, action, user) do
        Bodyguard.permit?(policy, action, user, {})
    end

    def w_permit?(policy, action, user) do
        &(Bodyguard.permit?(policy, action, user, &1)) 
    end

    defmacro __using__(_opts \\ []) do
        quote do 
            def permit?(action, user, object) do
                SignalNuisance.Authorization.permit?(__MODULE__, action, user, object)
            end

            def permit?(action, user) do
                SignalNuisance.Authorization.permit?(__MODULE__, action, user)
            end

            def w_permit?(action, user) do
                SignalNuisance.Authorization.w_permit?(__MODULE__, action, user)
            end
        end
    end
end
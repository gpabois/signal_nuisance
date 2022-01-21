defmodule SignalNuisance.Enterprise.Authorization do
    alias SignalNuisance.Enterprise

    @doc """
      Check if the user can access the enterprise dashboard.
    """
    def can_access(user, enterprise, context) do
      case context do
        :dashboard            -> enterprise |> Enterprise.is_member(user)
        :production_schedule  -> enterprise |> Enterprise.is_member(user)
        _ -> false
      end
    end
  
    def can_do(user, enterprise, action) do
      case action do
        :toggle_production -> enterprise |> Enterprise.is_member(user)
      end
    end
  
    @doc """
      Can
    """
    def can(user, enterprise, opts \\ []) do
      case opts do
        [{:access, context} | _] -> can_access(user, enterprise, context)
        [{:do, action} | _] -> can_do(user, enterprise, action)
        [_ | tail] -> can(user, enterprise, tail)
        [] -> false
      end
    end
  end
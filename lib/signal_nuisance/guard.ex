defmodule SignalNuisance.Guard do
    def is_member?(context) do
        case Keyword.has_key?(context, :enterprise) do
            true ->
                enterprise = Keyword.fetch!(context, :enterprise)
                user = Keyword.fetch!(context, :user)
                SignalNuisance.Enterprises.is_enterprise_member?(enterprise, user)
            _ -> false
        end
    end

    def is_authorized?(user, context) do
        SignalNuisance.Authorization.can user, context
    end

    def dispatch(check, context) do
        case check do
            {:is_authorized, user} ->
                if is_authorized?(user, context), do: :ok, else: {:error, :unauthorized}
            {:is_member, context} ->
                if is_member?(context), do: :ok, else: {:error, :not_member}
            {:are_same, a, b} ->
                if a == b, do: :ok, else: {:error, :not_same}
            {:are_different, a, b} ->
                if a != b, do: :ok, else: {:error, :same}
            _ -> {:error, :unknown_check}
        end
    end

    defmacro __using__(_opts) do
        quote do
            def is_possible(checks, context \\ []) do
                checks = Keyword.get(checks, :if, checks)
                case checks do
                [check | tail] -> 
                    with :ok <- SignalNuisance.Guard.dispatch(check, context) do
                        is_possible(tail, context)
                    end
                [] -> :ok
                end
            end
        end
    end
end
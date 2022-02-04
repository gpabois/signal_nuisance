defmodule SignalNuisance.Guard do
    use SignalNuisance.Context

    def is_member?(context) do
        case Keyword.has_key?(context, :enterprise) do
            true ->
                enterprise = Keyword.fetch!(context, :enterprise)
                user = Keyword.fetch!(context, :user)
                SignalNuisance.Enterprises.is_enterprise_member?(enterprise, user)
            _ -> false
        end
    end

    def is_authorized?(context) do
        SignalNuisance.Authorization.can context
    end

    def dispatch(check, context) do
        case check do
            {:is_authorized, {type, entity}} ->
                if is_authorized?(context ++ [entity(type, entity)]), do: :ok, else: {:error, :unauthorized}
            {:is_member, context} ->
                if is_member?(context), do: :ok, else: {:error, :not_member}
            {:are_same, {a, b}} ->
                if a == b, do: :ok, else: {:error, :are_different}
            {:are_different, {a, b}} ->
                if a != b, do: :ok, else: {:error, :are_same}
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
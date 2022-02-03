defmodule SignalNuisance.Authorization.Permission do
    @doc """
        All the permissions possible
    """
    @callback permissions() :: term

    defmacro __using__(_opts \\ []) do
        quote do
            @behaviour SignalNuisance.Authorization.Permission
            use Bitwise
            
            @doc false
            defp base_encode_permission(type) do
                case permissions() |> Enum.find_index(fn t -> t == type end) do
                    nil -> 0
                    shift -> 1 <<< shift
                end
            end

            def encode_permission(types) do
                case types do
                    [type | types] -> encode_permission(type) || encode_permission(types)
                    [] -> 0
                    type -> base_encode_permission(type)
                end
            end
        
            def add_permission(perms, types) when is_list(types) do
                perms ||| encode_permission(types)
            end   
        
            def remove_permission(perms, types) do
                perms &&& ~~~(encode_permission(types))
            end

            def is_permission?(permissions, type) do
                (permissions &&& encode_permission(type)) === encode_permission(type)
            end
        end
    end
end
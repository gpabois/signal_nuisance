defmodule SignalNuisance.Authorization.Permission do
    @doc """
        All the permissions possible
    """
    @callback permissions() :: term
    @callback permission_entity_dispatch(term) :: term

    defmacro __using__(_opts \\ []) do
        quote do
            @behaviour SignalNuisance.Authorization.Permission
            use Bitwise
    
            @doc """
                Check if a user has an establishment-related permission.

                Always true, if the user has the enterprise's permission {:manage, :establishments}
            """
            def has_permission?(entity, context, permissions) do
                case permission_entity_dispatch(entity) do
                    nil -> raise "Unknown entity"
                    entity_based -> entity_based.has_permission?(entity, context, permissions)
                end
            end

            def grant(entity, context, permissions) do
                case permission_entity_dispatch(entity) do
                    nil -> raise "Unknown entity"
                    entity_based -> entity_based.grant(entity, context, permissions)
                end
            end

            def revoke_all(entity, context) do
                case permission_entity_dispatch(entity) do
                    nil -> raise "Unknown entity"
                    entity_based -> entity_based.revoke_all(entity, context)
                end
            end

            def revoke(entity, context, permissions) do
                case permission_entity_dispatch(entity) do
                    nil -> raise "Unknown entity"
                    entity_based -> entity_based.revoke(entity, context, permissions)
                end
            end

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
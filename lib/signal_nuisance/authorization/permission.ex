defmodule SignalNuisance.Authorization.Permission do
    @resource_based %{
        enterprise: SignalNuisance.Enterprises.Authorization.EnterprisePermission,
        establishment: SignalNuisance.Enterprises.Authorization.EstablishmentPermission,
        alert: SignalNuisance.Reporting.Authorization.AlertPermission
    }

    use SignalNuisance.Context

    @doc false
    defp extract_entity(entity) do
        case entity do
            [entity] -> entity
            entity -> entity
        end
    end

    def resource_related(context) do 
        case opts |> Enum.filter(fn ({k, _v}) -> Map.has_key?(@resource_based, k) end) do
            [{resource_type, _} | _] -> {:yes, @resource_based[resource_type]}
            [] -> :no
        end
    end

    def has?(entity, permissions, context) do
        entity = extract_entity(entity)
        case resource_related(context) do
            {:yes, hdlr} -> hdlr.has?(entity, permissions, context)
            :no -> false
        end
    end

    def grant(entity, permissions, context) do
        entity = extract_entity(entity)
        case resource_related(context) do
            {:yes, hdlr} -> hdlr.grant(entity, permissions, context)
            :no -> false
        end
    end

    def revoke(entity, permissions, context) do
        entity = extract_entity(entity)
        case resource_related(context) do
            {:yes, hdlr} -> hdlr.revoke(entity, permissions, context)
            :no -> false
        end
    end
    
    def revoke_all(entity, context) do
        entity = extract_entity(entity)
        case resource_related(context) do
            {:yes, hdlr} -> hdlr.revoke_all(entity, context)
            :no -> false
        end
    end

    @doc """
        All the permissions possible
    """
    @callback has?(term) :: term
    @callback grant(context) :: term
    @callback revoke(context) :: term
    @callback revoke_all(context) :: term

    @doc """
        ## Parameters
        - permissions: Mandatory
        - dispatch_by_entity : Optional [entity_type: DelegatedModule]
        - roles: [
            owner: [...]
        ]
        - encoding: :byte
        
    """
    defmacro __using__(opts \\ []) do
        permissions     = Keyword.fetch!(opts, :permissions)
        is_delegating   = Keyword.has_key?(opts, :dispatch_by_entity)
        encoding        = Keyword.get(opts, :encoding, nil)
        roles           = Keyword.get(opts, :roles, [])
        entity_delegations = if is_delegating do 
            Keyword.fetch!(opts, :permissions)
        else
            []
        end

        quote do
            @behaviour SignalNuisance.Authorization.Permission

            use SignalNuisance.Context
            use Bitwise
            
            unquote do
                if is_delegating do
                    quote do
                        @doc false
                        defp delegate_by_entity(entity) do
                            {type, _entity} = entity
                            case Keyword.fetch(unquote(entity_delegations), type) do
                                {:ok, hdlr} -> hdlr
                                {:error, _} -> nil
                            end
                            
                        end
                        
                        @doc false
                        defp check_roles(context) do
                            case Keyword.fetch(context, :role) do
                                {:ok, role} -> 
                                    case Keyword.get(unquote(roles), role, []) do
                                        permissions -> permissions
                                        [] -> []
                                    end
                                _ -> []
                            end
                            
                        end

                        @doc """
                            Check if an entity has the permissions.
                        """
                        def has?(entity, permissions, context) do
                            permissions = permissions ++ check_roles(context)
                            case delegate_by_entity(entity) do
                                nil -> false
                                hdlr -> hdlr.has?(entity, permissions, context)
                            end
                        end

                        def grant(entity, permissions, context) do
                            permissions = permissions ++ check_roles(context)
                            case delegate_by_entity(entity) do
                                nil -> {:error, :unmanaged_or_no_entity}
                                hdlr -> hdlr.grant(entity, permissions, context)
                            end
                        end
            
                        def revoke_all(entity, context) do
                            permissions = permissions ++ check_roles(context)
                            case delegate_by_entity(entity) do
                                nil -> {:error, :unmanaged_entity}
                                hdlr -> hdlr.revoke_all(entity, context)
                            end
                        end
            
                        def revoke(entity, permissions, context) do
                            permissions = permissions ++ check_roles(context)
                            case delegate_by_entity(entity) do
                                nil -> {:error, :unmanaged_entity}
                                hdlr -> hdlr.revoke(entity, permissions, context)
                            end
                        end
            
                    end
                end
            end

            def permissions(), do: unquote(permissions)

            def is_permission?(permission) do
                permission in unquote do: permissions
            end

            def get_permissions(context) do
                context |> Enum.filter(&is_permission?/1)
            end

            unquote do
                if encoding == :byte do
                    quote do
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
                    
                        def add_permission(permissions, types) when is_list(types) do
                            permissions ||| encode_permission(types)
                        end   
                    
                        def remove_permission(permissions, types) do
                            permissions &&& ~~~(encode_permission(types))
                        end

                        def is_permission?(permissions, type) do
                            (permissions &&& encode_permission(type)) === encode_permission(type)
                        end
                    end
                end
            end
        end
    end
end
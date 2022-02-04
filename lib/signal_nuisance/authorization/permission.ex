defmodule SignalNuisance.Authorization.Permission do
    @resource_based %{
        enterprise: SignalNuisance.Enterprises.Authorization.EnterprisePermission,
        establishment: SignalNuisance.Enterprises.Authorization.EstablishmentPermission,
        alert: SignalNuisance.Reporting.Authorization.AlertPermission
    }

    use SignalNuisance.Context

    def resource_related(context) do 
        case opts |> Enum.filter(fn ({k, _v}) -> Map.has_key?(@resource_based, k) end) do
            {:yes, @resource_based[resource_type]}
            [] -> :no
        end
    end

    def has?(context) do
        case resource_related(context) do
            {:yes, hdlr} -> hdlr.has?(context),
            _ -> false
        end
    end

    def grant(context) do
        case resource_related(context) do
            {:yes, hdlr} -> hdlr.grant(context),
            _ -> false
        end
    end

    def revoke(context) do
        case resource_related(context) do
            {:yes, hdlr} -> hdlr.revoke(context),
            _ -> false
        end
    end
    
    def revoke_all(context) do
        case resource_related(context) do
            {:yes, hdlr} -> hdlr.revoke_all(context),
            _ -> false
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
        permissions = Keyword.fetch!(opts, :permissions)
        is_delegating = Keyword.has_key?(opts, :dispatch_by_entity)
        encoding = Keyword.get(opts, :encoding, nil)
        roles = Keyword.get(opts, :roles, [])
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
                        defp delegate_by_entity(context) do
                            [{type, _entity} | _] = get_entities(context)
                            case Keyword.fetch(unquote(entity_delegations), type) do
                                {:ok, hdlr} -> hdlr
                                {:error, _} -> nil
                            end
                            
                        end
                        
                        defp check_roles(context) do
                            case Keyword.fetch(context, :role) do
                                {:ok, role} -> 
                                    case Keyword.get(unquote(roles), role, []) do
                                        permissions -> context ++ permissions
                                        [] -> context
                                    end
                                _ -> context
                            end
                            
                        end

                        @doc """
                            Check if an entity has the permissions.
                        """
                        def has?(context) do
                            context = check_roles(context)
                            case delegate_by_entity(context) do
                                nil -> false
                                hdlr -> hdlr.has?(context)
                            end
                        end

                        def grant(context) do
                            context = check_roles(context)
                            case delegate_by_entity(context) do
                                nil -> {:error, :unmanaged_or_no_entity}
                                hdlr -> hdlr.grant(context)
                            end
                        end
            
                        def revoke_all(context) do
                            context = check_roles(context)
                            case delegate_by_entity(context) do
                                nil -> {:error, :unmanaged_or_no_entity}
                                hdlr -> hdlr.revoke_all(context)
                            end
                        end
            
                        def revoke(context) do
                            context = check_roles(context)
                            case delegate_by_entity(context) do
                                nil -> {:error, :unmanaged_or_no_entity}
                                hdlr -> hdlr.revoke(context)
                            end
                        end
            
                    end
                end
            end

            def permissions(), do: unquote(permissions)

            def is_permission?(permission) do
                permission in unquote, do: permissions
            end

            def get_permissions(context) do
                context |> Enum.filter(fn x -> is_permission?(x))
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
        end
    end
end
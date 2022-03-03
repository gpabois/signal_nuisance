defmodule SignalNuisance.Authorization.Permission do
    @resource_delegations [
        {SignalNuisance.Enterprises.Enterprise, SignalNuisance.Enterprises.Authorization.EnterprisePermission},
        {SignalNuisance.Enterprises.Establishment,  SignalNuisance.Enterprises.Authorization.EstablishmentPermission},
        alert: SignalNuisance.Reporting.Authorization.AlertPermission
    ]

    @doc false
    defp extract_entity(entity) do
        case entity do
            [entity] -> entity
            entity -> entity
        end
    end

    defp delegate_by_resource(context) do
        type = case context do
            {type, _entity} -> type
            %type{} -> type
        end

        case Keyword.fetch(@resource_delegations, type) do
            {:ok, hdlr} -> {:yes, hdlr}
            {:error, _} -> :no
        end

    end

    def has?(entity, permissions, context) do
        entity = extract_entity(entity)
        case delegate_by_resource(context) do
            {:yes, hdlr} -> hdlr.has?(entity, permissions, context)
            :no -> false
        end
    end

    def grant(entity, permissions, context) do
        entity = extract_entity(entity)
        case delegate_by_resource(context) do
            {:yes, hdlr} -> hdlr.grant(entity, permissions, context)
            :no -> false
        end
    end

    def revoke(entity, permissions, context) do
        entity = extract_entity(entity)
        case delegate_by_resource(context) do
            {:yes, hdlr} -> hdlr.revoke(entity, permissions, context)
            :no -> false
        end
    end

    def revoke_all(entity, context) do
        entity = extract_entity(entity)
        case delegate_by_resource(context) do
            {:yes, hdlr} -> hdlr.revoke_all(entity, context)
            :no -> false
        end
    end

    @doc """
        All the permissions possible
    """
    @callback has?(term, term, term) :: term
    @callback grant(term, term, term) :: term
    @callback revoke(term, term, term) :: term
    @callback revoke_all(term, term) :: term

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
            Keyword.fetch!(opts, :dispatch_by_entity)
        else
            []
        end

        quote do
            use Bitwise

            unquote do
                if is_delegating do
                    quote do
                        @doc false
                        defp delegate_by_entity(entity) do
                            type = case entity do
                                {type, _entity} -> type
                                %type{} -> type
                            end

                            case Keyword.fetch(unquote(entity_delegations), type) do
                                {:ok, hdlr} -> {:yes, hdlr}
                                {:error, _} -> :no
                            end
                        end

                        @doc false
                        def by_role(role) do
                            Keyword.get(unquote(roles), role, [])
                        end

                        @doc """
                            Check if an entity has the permissions.
                        """
                        def has?(entity, permissions, context) do
                            case delegate_by_entity(entity) do
                                :no -> false
                                {:yes, hdlr} -> hdlr.has?(entity, permissions, context)
                            end
                        end

                        def grant(entity, permissions, context) do
                            case delegate_by_entity(entity) do
                                :no -> {:error, :unmanaged_or_no_entity}
                                {:yes, hdlr}  -> hdlr.grant(entity, permissions, context)
                            end
                        end

                        def revoke_all(entity, context) do
                            case delegate_by_entity(entity) do
                                :no -> {:error, :unmanaged_entity}
                                {:yes, hdlr}  -> hdlr.revoke_all(entity, context)
                            end
                        end

                        def revoke(entity, permissions, context) do
                            case delegate_by_entity(entity) do
                                :no -> {:error, :unmanaged_entity}
                                {:yes, hdlr} -> hdlr.revoke(entity, permissions, context)
                            end
                        end

                    end
                end
            end

            def permissions(), do: unquote(permissions)

            def is_permission?(permission) do
                permission in unquote do: permissions
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

            @behaviour SignalNuisance.Authorization.Permission
        end
    end
end

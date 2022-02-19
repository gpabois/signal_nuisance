defmodule SignalNuisance.Authorization do
    use SignalNuisance.Context

    @resource_based %{
        enterprise:     SignalNuisance.Enterprises.EnterpriseAuthorization,
        establishment:  SignalNuisance.Enterprises.EstablishmentAuthorization,
        alert:          SignalNuisance.Reporting.AlertAuthorization
    }

    def resource_related(context) do 
        case opts |> Enum.filter(fn ({k, _v}) -> Map.has_key?(@resource_based, k) end) do
            [{resource_type, _} | _] -> {:yes, @resource_based[resource_type]}
            [] -> :no
        end
    end
    
    defp check_entity(entity) do
        case entity do
            [{type, entity} | _] -> {type, entity}
            _ -> entity
        end
    end

    @doc """
        Check if, based on the context, the action can be performed.

        ## Examples
        iex> Authorization.can user: user, enterprise: enterprise, access: :dashboard
    """
    def can?(entity, context) do
        entity = check_entity(entity)
        case resource_related(context) do
            :no -> false
            {:yes, hdlr} -> hdlr.can?(entity, context)
        end
    end

    @callback can?(term, term) :: term

    @doc false
    defmacrop check_parse(check) do
        case check do
            {:permission, hdlr} ->
                quote do
                    case unquote(hdlr).get_permissions(context) do
                        [] -> false
                        permissions -> unquote(hdlr).has?(entity, permissions, context)
                    end 
                end 
        end
    end

    @doc false
    defmacrop cond_or(checks) do

    end

    defmacro __using__(opts \\ []) do
        permissions = Keyword.get(opts, :permissions, nil)
        ors = Keyword.get_values(opts, :or)
        quote do
            @behaviour SignalNuisance.Authorization
        end

        quote do
            def can?(entity, context) do
                unquote do
                    if permissions != nil do
                        quote do 
                            case unquote(permissions).get_permissions(context) do
                                [] -> false,
                                permissions -> unquote(permissions).has?(entity, permissions, context)
                            end
                        end
                    end
                end
            end
        end

    end

    # use Authorization, or: fn entity, context -> Authorization.can?(entity, manage: enterprise) end
end
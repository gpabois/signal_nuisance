defmodule SignalNuisance.Context do
    @resources [
        :enteprise,
        :establishment,
        :alert
    ]

    @entities [
        :user,
        :email
    ]

    def is_entity?(type) do
        type in @entities
    end

    def is_resource?(type) do
        type in @resources
    end

    def get_entities(context) do
        case context do
            [{type, resource} | context] ->
                if is_entity?(type) do
                    [{type, entity}]
                else
                    []
                end ++ get_entities(context)
            [] -> []
        end
    end

    def get_resources(context) do
        case context do
            [{type, resource} | context] ->
                if is_resource?(type) do
                    [{type, resource}]
                else
                    []
                end ++ get_resources(context)
            [] -> []
        end
    end

    defmacro __using__(_opts) do
        quote do
            def get_entities(context) do
                SignalNuisance.Context.get_entities(context)
            end

            def get_resources(context) do
                SignalNuisance.Context.get_resources(context)
            end

            def get_resource!(context, type) do
                SignalNuisance.Context.get_resources(context) |> Keyword.fetch!(type)
            end

            def get_resource(context, type) do
                SignalNuisance.Context.get_resources(context) |> Keyword.fetch(type)
            end

            def get_entity(context, type) do
                SignalNuisance.Context.get_entities(context) |> Keyword.fetch(type)
            end

            def get_entity!(context, type) do
                SignalNuisance.Context.get_entities(context) |> Keyword.fetch!(type)
            end

            def entity([{type, entity}]) do
                {:entity, {type, entity}}
            end
        
            def resource([{type, resource}]) do
                {:resource, {type, resource}}
            end
            
        end
    end
end
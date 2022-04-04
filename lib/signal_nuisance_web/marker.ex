defmodule SignalNuisanceWeb.MarkerHelpers do
    alias SignalNuisance.Enterprises.Establishment

    defp marker_id(data) do
        id = :crypto.hash(:sha, "#{data.type}-#{data.id}") |> Base.encode64
        "marker-#{id}"
    end

    defp marker_data(entity) do
        case entity do
            %Establishment{} -> %{
                type: "establishment",
                id: entity.id
            }
            _ -> %{}
        end
    end

    defp marker_label(entity) do
        case entity do
            %Establishment{} -> entity.name
            _ -> ""
        end
    end

    def marker(entity) do
        data = marker_data(entity)
        id = marker_id(data)
        label = marker_label(entity)
        
        %{
            id: id,
            data: data,
            label: label,
            coordinates: entity.loc
        }
    end
end
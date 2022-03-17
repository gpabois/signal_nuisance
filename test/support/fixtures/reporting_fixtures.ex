defmodule SignalNuisance.ReportingFixtures do
    def random_category, do: SignalNuisance.Reporting.AlertType.categories() |> Enum.random()
    def random_language_code, do: Enum.random(["fr", "en"])
    def unique_intensity, do: Enum.random(0..10)
    def unique_label, do: "label_#{System.unique_integer()}"
    def unique_description, do: "description #{System.unique_integer()}"
    def unique_loc, do: Geo.Fixtures.random_point()

    def valid_alert_type_translation_attributes(attrs \\ %{}) do
        compl = if Map.has_key?(attrs, :alert_type_id) do
            %{}
        else
            %{
                alert_type_id: alert_type_fixture().id
            }
        end |> Map.merge(%{
            language_code: random_language_code(),
            label: unique_label(),
            description: unique_description()
        })

        Enum.into(attrs, compl)
    end

    def alert_type_translation_fixture(attrs \\ %{}) do
        {:ok, alert_type_tl} = attrs
        |> valid_alert_type_translation_attributes()
        |> SignalNuisance.Reporting.create_alert_type_translation()
        alert_type_tl
    end

    def valid_alert_type_attributes(attrs \\ %{}) do
      Enum.into(attrs, %{
        category: random_category(),
        label: unique_label(),
        description: unique_description()
      })
    end

    def alert_type_fixture(attrs \\ %{}) do
        {:ok, alert_type} = attrs
        |> valid_alert_type_attributes()
        |> SignalNuisance.Reporting.create_alert_type()
        alert_type
    end

    def valid_alert_attributes(attrs \\ %{}) do
        %{coordinates: {long, lat}} = unique_loc()

        compl = if Map.has_key?(attrs, :alert_type_id) do
            %{

            }
        else
            %{
                alert_type_id: alert_type_fixture().id
            }
        end |> Map.merge(%{
            intensity: unique_intensity(),
            loc_long: long,
            loc_lat: lat
        })
        Enum.into(attrs, compl)
    end

    def alert_fixture(attrs \\ %{}) do
        {:ok, alert} = attrs
        |> valid_alert_attributes()
        |> SignalNuisance.Reporting.create_alert()
        alert
    end
end
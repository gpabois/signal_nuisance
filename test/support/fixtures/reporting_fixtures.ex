defmodule SignalNuisance.ReportingFixtures do
    def random_category, do: Enum.random(["smell", "noise"])
    def unique_label, do: "label_#{System.unique_integer()}"
    def unique_description, do: "description #{System.unique_integer()}"
    def unique_loc, do: Geo.Fixtures.random_point()

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
    end

    def valid_alert_attributes(attrs \\ %{}) do
        Enum.into(attrs, %{
            alert_type_id: alert_type_fixture().id
        })
    end

    def alert_fixture(attrs \\ %{}) do
        {:ok, alert} = attrs
        |> valid_alert_attributes()
        |> SignalNuisance.Reporting.create_alert()
    end
end
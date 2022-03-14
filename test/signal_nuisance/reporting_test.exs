defmodule SignalNuisance.ReportingTest do
    use SignalNuisance.DataCase
    alias SignalNuisance.Reporting
    import SignalNuisance.ReportingFixtures

    describe "create_alert_type/1" do
        test "create a valid alert type" do
            alert_type_attrs = valid_alert_type_attributes()

            assert {:ok, _alert_type} = Reporting.create_alert_type(alert_type_attrs)
        end
    end
end
  
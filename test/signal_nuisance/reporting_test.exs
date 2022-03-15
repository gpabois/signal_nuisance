defmodule SignalNuisance.ReportingTest do
    use SignalNuisance.DataCase

    alias SignalNuisance.Reporting
    import SignalNuisance.ReportingFixtures

    describe "create_alert/1" do
        test "create a valid alert" do
            alert_attrs = valid_alert_attributes()
            assert {:ok, _alert} = Reporting.create_alert(alert_attrs)
        end
    end

    describe "create_alert_type/1" do
        test "create a valid alert type" do
            alert_type_attrs = valid_alert_type_attributes()
            assert {:ok, _alert_type} = Reporting.create_alert_type(alert_type_attrs)
        end

        test "requires a valid category" do
            alert_type_attrs = valid_alert_type_attributes(category: "garbage")

            {:error, changeset} = Reporting.create_alert_type(alert_type_attrs)
            assert %{
                category: ["is invalid"]
              } = errors_on(changeset)
        end
    end

    describe "create_alert_type_translation/1" do
        test "create a valid alert type translation" do
            alert_type = alert_type_fixture()
            alert_type_tl_attrs = valid_alert_type_translation_attributes(%{alert_type_id: alert_type.id})           
            assert {:ok, _alert_type_tl} = Reporting.create_alert_type_translation(alert_type_tl_attrs)
        end
    end

    test "get_alert_types_by_category/1" do
        %{category: category} = alert_type = alert_type_fixture()
        assert Reporting.get_alert_types_by_category(category) == [alert_type]
    end

    describe "get_alert_types_by_category/2 (with translation)" do
        test "when no translation is available" do
            %{category: category} = alert_type = alert_type_fixture()
            assert Reporting.get_alert_types_by_category(category, "lang") == [alert_type]
        end

        test "when a translation is available" do
            %{category: category} = alert_type = alert_type_fixture()
            alert_type_tl = alert_type_translation_fixture(%{alert_type_id: alert_type.id})
            alert_type_translated = alert_type |> Map.merge(%{
                label: alert_type_tl.label,
                description: alert_type_tl.description
            })
            
            refute Reporting.get_alert_types_by_category(category, alert_type_tl.language_code) == [alert_type] 
            assert Reporting.get_alert_types_by_category(category, alert_type_tl.language_code) == [alert_type_translated]
        end
    end
end
  
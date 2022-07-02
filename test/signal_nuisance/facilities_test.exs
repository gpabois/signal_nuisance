defmodule SignalNuisance.FacilitiesTest do
  use SignalNuisance.DataCase

  alias SignalNuisance.Facilities

  describe "facility_alerts_bindings" do
    alias SignalNuisance.Facilities.FacilityAlertBinding

    import SignalNuisance.FacilitiesFixtures

    @invalid_attrs %{}

    test "list_facility_alerts_bindings/0 returns all facility_alerts_bindings" do
      facility_alert_binding = facility_alert_binding_fixture()
      assert Facilities.list_facility_alerts_bindings() == [facility_alert_binding]
    end

    test "get_facility_alert_binding!/1 returns the facility_alert_binding with given id" do
      facility_alert_binding = facility_alert_binding_fixture()
      assert Facilities.get_facility_alert_binding!(facility_alert_binding.id) == facility_alert_binding
    end

    test "create_facility_alert_binding/1 with valid data creates a facility_alert_binding" do
      valid_attrs = %{}

      assert {:ok, %FacilityAlertBinding{} = facility_alert_binding} = Facilities.create_facility_alert_binding(valid_attrs)
    end

    test "create_facility_alert_binding/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Facilities.create_facility_alert_binding(@invalid_attrs)
    end

    test "update_facility_alert_binding/2 with valid data updates the facility_alert_binding" do
      facility_alert_binding = facility_alert_binding_fixture()
      update_attrs = %{}

      assert {:ok, %FacilityAlertBinding{} = facility_alert_binding} = Facilities.update_facility_alert_binding(facility_alert_binding, update_attrs)
    end

    test "update_facility_alert_binding/2 with invalid data returns error changeset" do
      facility_alert_binding = facility_alert_binding_fixture()
      assert {:error, %Ecto.Changeset{}} = Facilities.update_facility_alert_binding(facility_alert_binding, @invalid_attrs)
      assert facility_alert_binding == Facilities.get_facility_alert_binding!(facility_alert_binding.id)
    end

    test "delete_facility_alert_binding/1 deletes the facility_alert_binding" do
      facility_alert_binding = facility_alert_binding_fixture()
      assert {:ok, %FacilityAlertBinding{}} = Facilities.delete_facility_alert_binding(facility_alert_binding)
      assert_raise Ecto.NoResultsError, fn -> Facilities.get_facility_alert_binding!(facility_alert_binding.id) end
    end

    test "change_facility_alert_binding/1 returns a facility_alert_binding changeset" do
      facility_alert_binding = facility_alert_binding_fixture()
      assert %Ecto.Changeset{} = Facilities.change_facility_alert_binding(facility_alert_binding)
    end
  end
end

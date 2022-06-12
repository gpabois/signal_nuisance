defmodule SignalNuisanceWeb.Administration.AdministrationFacilityControllerTest do
  use SignalNuisanceWeb.ConnCase, async: true

  setup :register_and_log_in_user

  import SignalNuisance.FacilitiesFixtures
  alias SignalNuisance.Facilities

  alias SignalNuisance.Administration

  defp grant_credentials(user) do
    Administration.add_administrator(user)
    Administration.grant_permissions(user, manage: :facilities)
  end

  describe "GET /admin/facilities" do
      test "accéder à la page sans avoir l'autorisation", %{conn: conn} do
        conn = get(conn, Routes.administration_facility_path(conn, :index))
        response = html_response(conn, 403)
        assert response =~ "Unauthorized"
      end

      test "accéder à la page avec l'autorisation", %{conn: conn, user: user} do
        grant_credentials(user)
        conn = get(conn, Routes.administration_facility_path(conn, :index))
        response = html_response(conn, 200)
        assert response =~ "Liste des installations"
      end
  end

  describe "GET /admin/facilities/:id" do
    test "accéder à la page sans avoir l'autorisation", %{conn: conn} do
      facility = facility_fixture()
      conn = get(conn, Routes.administration_facility_path(conn, :show, facility))
      response = html_response(conn, 403)
      assert response =~ "Unauthorized"
    end

    test "accéder à la page avec l'autorisation", %{conn: conn, user: user} do
      grant_credentials(user)
      facility = facility_fixture()
      conn = get(conn, Routes.administration_facility_path(conn, :show, facility))
      response = html_response(conn, 200)
      assert response =~ facility.name
    end
  end

  describe "GET /admin/facilities/:id/toggle_validation" do
    test "executer l'action sans avoir l'autorisation", %{conn: conn} do
      facility = facility_fixture()
      conn = get(conn, Routes.administration_facility_path(conn, :toggle_validation, facility))
      response = html_response(conn, 403)
      assert response =~ "Unauthorized"
    end

    test "executer l'action avec l'autorisation", %{conn: conn, user: user} do
      grant_credentials(user)
      facility = facility_fixture()
      conn = get(conn, Routes.administration_facility_path(conn, :toggle_validation, facility))
      assert redirected_to(conn) == Routes.administration_facility_path(conn, :show, facility)

      assert %{valid: true} = Facilities.get_facility!(facility.id)
    end
  end

  describe "GET /admin/facilities/:id/delete" do
    test "executer l'action sans avoir l'autorisation", %{conn: conn} do
      facility = facility_fixture()
      conn = get(conn, Routes.administration_facility_path(conn, :delete, facility))
      response = html_response(conn, 403)
      assert response =~ "Unauthorized"
    end

    test "executer l'action avec l'autorisation", %{conn: conn, user: user} do
      grant_credentials(user)
      facility = facility_fixture()
      conn = get(conn, Routes.administration_facility_path(conn, :delete, facility))
      assert redirected_to(conn) == Routes.administration_facility_path(conn, :index)

      assert_raise Ecto.NoResultsError, fn -> Facilities.get_facility!(facility.id) end
    end
  end
end

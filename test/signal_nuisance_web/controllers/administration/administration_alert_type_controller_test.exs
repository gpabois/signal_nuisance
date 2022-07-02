defmodule SignalNuisanceWeb.Administration.AdministrationAlertTypeControllerTest do
  use SignalNuisanceWeb.ConnCase, async: true

  setup :register_and_log_in_user

  import SignalNuisance.ReportingFixtures
  alias SignalNuisance.Reporting

  alias SignalNuisance.Administration

  defp grant_credentials(user) do
    Administration.add_administrator(user)
    Administration.grant_permissions(user, manage: :alerts)
  end

  describe "GET /admin/alerts/types" do
      test "accéder à la page sans avoir l'autorisation", %{conn: conn} do
        conn = get(conn, Routes.administration_alert_type_path(conn, :index))
        response = html_response(conn, 403)
        assert response =~ "Unauthorized"
      end

      test "accéder à la page avec l'autorisation", %{conn: conn, user: user} do
        grant_credentials(user)
        conn = get(conn, Routes.administration_alert_type_path(conn, :index))
        response = html_response(conn, 200)
        assert response =~ "Liste des types de nuisances"
      end
  end

  describe "GET|POST /admin/alert/types/new" do
    test "accéder à la page sans avoir l'autorisation", %{conn: conn} do
      conn = get(conn, Routes.administration_alert_type_path(conn, :new))
      response = html_response(conn, 403)
      assert response =~ "Unauthorized"
    end

    test "accéder à la page avec l'autorisation", %{conn: conn, user: user} do
      grant_credentials(user)
      conn = get(conn, Routes.administration_alert_type_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "Nouveau type de nuisance"
    end

    test "créer un nouveau type d'alerte", %{conn: conn, user: user} do
      grant_credentials(user)
      alert_type_attributes = valid_alert_type_attributes()
      conn = post(conn,
        Routes.administration_alert_type_path(conn, :new),
        %{"alert_type" => alert_type_attributes}
      )

      assert redirected_to(conn) == Routes.administration_alert_type_path(conn, :index)
    end
  end

  describe "GET /admin/alerts/types/:id/delete" do
    test "executer l'action sans avoir l'autorisation", %{conn: conn} do
      alert_type = alert_type_fixture()
      conn = get(conn, Routes.administration_alert_type_path(conn, :delete, alert_type))
      response = html_response(conn, 403)
      assert response =~ "Unauthorized"
    end

    test "executer l'action avec l'autorisation", %{conn: conn, user: user} do
      grant_credentials(user)
      alert_type = alert_type_fixture()

      conn = get(conn, Routes.administration_alert_type_path(conn, :delete, alert_type))
      assert redirected_to(conn) == Routes.administration_alert_type_path(conn, :index)

      assert_raise Ecto.NoResultsError, fn -> Reporting.get_alert_type!(alert_type.id) end
    end
  end
end

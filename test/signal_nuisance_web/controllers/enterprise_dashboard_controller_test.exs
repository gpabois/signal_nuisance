defmodule SignalNuisanceWeb.EnterpriseDashboardControllerTest do
    use SignalNuisanceWeb.ConnCase, async: true

    setup :register_and_log_in_user

    alias SignalNuisance.Enterprises
    import SignalNuisance.EnterprisesFixtures

    describe "GET /enterprises/:slug/dashboard" do
        test "accéder à la page quand l'utilisateur est autorisé", %{conn: conn, user: user} do
          enterprise = enterprise_fixture(%{})

          Enterprises.set_permissions(user, [access: :common], enterprise)

          conn = get(conn, Routes.enterprise_dashboard_path(conn, :show, enterprise.slug))
          response = html_response(conn, 200)
          assert response =~ enterprise.name
        end

        test "rediriger si l'utilisateur n'est pas connecté" do
          conn = build_conn()
          conn = get(conn, Routes.enterprise_registration_path(conn, :new))
          assert redirected_to(conn) == Routes.user_session_path(conn, :new)
        end

        test "rediriger vers la page 403 quand l'utilisateur n'est pas autorisé", %{conn: conn} do
          enterprise = enterprise_fixture(%{})

          conn = get(conn, Routes.enterprise_dashboard_path(conn, :show, enterprise.slug))
          response = html_response(conn, 403)
          assert response =~ "Unauthorized"
        end
    end


end

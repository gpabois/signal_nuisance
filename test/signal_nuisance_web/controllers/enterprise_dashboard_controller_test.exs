defmodule SignalNuisanceWeb.EnterpriseDashboardControllerTest do
    use SignalNuisanceWeb.ConnCase, async: true

    setup :register_and_log_in_user

    import SignalNuisance.EnterprisesFixtures

    describe "GET /enterprises/:slug/dashboard when has permissions" do       
        test "renders page", %{conn: conn, user: user} do
          enterprise = enterprise_fixture(%{}, register: user)

          conn = get(conn, Routes.enterprise_dashboard_path(conn, :show, enterprise.slug))
          response = html_response(conn, 200)
          assert response =~ enterprise.name
        end
    
        test "redirects if user is not logged in" do
          conn = build_conn()
          conn = get(conn, Routes.enterprise_registration_path(conn, :new))
          assert redirected_to(conn) == Routes.user_session_path(conn, :new)
        end

        test "403 if user has not the right permissions", %{conn: conn} do
          enterprise = enterprise_fixture(%{})

          conn = get(conn, Routes.enterprise_dashboard_path(conn, :show, enterprise.slug))
          response = html_response(conn, 403)
          assert response =~ "Unauthorized"
        end
        
    end
end
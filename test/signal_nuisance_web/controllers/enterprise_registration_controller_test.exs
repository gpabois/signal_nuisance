defmodule SignalNuisanceWeb.EnterpriseRegistrationControllerTest do
    use SignalNuisanceWeb.ConnCase, async: true

    setup :register_and_log_in_user

    describe "GET /enterprises/register" do
        test "renders page", %{conn: conn} do
          conn = get(conn, Routes.enterprise_registration_path(conn, :new))
          response = html_response(conn, 200)
          assert response =~ "<h1>Register an enterprise</h1>"
        end
    
        test "redirects if user is not logged in" do
          conn = build_conn()
          conn = get(conn, Routes.enterprise_registration_path(conn, :new))
          assert redirected_to(conn) == Routes.user_session_path(conn, :new)
        end
      end
end
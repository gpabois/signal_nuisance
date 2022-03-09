defmodule SignalNuisanceWeb.EnterpriseRegistrationControllerTest do
    use SignalNuisanceWeb.ConnCase, async: true

    setup :register_and_log_in_user

    import SignalNuisance.EnterprisesFixtures

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


    describe "POST /enterprises/register" do
      @tag :capture_log
      test "registers an enterprise", %{conn: conn} do
        enterprise_attributes = valid_enterprise_attributes()
        slug = Slugy.slugify(enterprise_attributes.name)

        conn =
          post(conn, Routes.enterprise_registration_path(conn, :create), %{
            "enterprise" => enterprise_attributes
          })
        
        enterprise_redir = Routes.enterprise_dashboard_path(conn, :show, slug)
        assert redirected_to(conn) == enterprise_redir
  
        # Now do a logged in request and assert on the menu
        conn = get(conn, enterprise_redir)
        response = html_response(conn, 200)
        assert response =~ enterprise_attributes.name
      end
    end
end
defmodule SignalNuisanceWeb.FacilityRegistrationControllerTest do
    use SignalNuisanceWeb.ConnCase, async: true

    setup :register_and_log_in_user

    import SignalNuisance.FacilitiesFixtures

    describe "GET /facilities/register" do
        test "accéder à la page", %{conn: conn} do
          conn = get(conn, Routes.facility_registration_path(conn, :new))
          response = html_response(conn, 200)
          assert response =~ "<h1>Register an enterprise</h1>"
        end

        test "rediriger si l'utilisateur n'est pas connecté" do
          conn = build_conn()
          conn = get(conn, Routes.facility_registration_path(conn, :new))
          assert redirected_to(conn) == Routes.user_session_path(conn, :new)
        end
    end


    describe "POST /facilities/register" do
      @tag :capture_log
      test "enregistrer une installation", %{conn: conn} do
        facility_attributes = valid_facility_attributes()

        conn =
          post(conn, Routes.facility_registration_path(conn, :create), %{
            "facility" => facility_attributes
          })

        enterprise_redir = Routes.facility_dashboard_live_path(conn, :show, slug)
        assert redirected_to(conn) == enterprise_redir

        # Now do a logged in request and assert on the menu
        conn = get(conn, enterprise_redir)
        response = html_response(conn, 200)
        assert response =~ enterprise_attributes.name
      end
    end
end

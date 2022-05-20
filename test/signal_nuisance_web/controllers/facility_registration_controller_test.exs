defmodule SignalNuisanceWeb.FacilityRegistrationControllerTest do
    use SignalNuisanceWeb.ConnCase, async: true

    setup :register_and_log_in_user

    import SignalNuisance.FacilitiesFixtures

    describe "GET /facilities/register" do
        test "accéder à la page", %{conn: conn} do
          conn = get(conn, Routes.facility_registration_path(conn, :new))
          response = html_response(conn, 200)
          assert response =~ "Enregistrer une installation"
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
        facility_attributes = valid_facility_form_attributes()

        conn =
          post(conn, Routes.facility_registration_path(conn, :create), %{
            "facility" => facility_attributes
          })

        assert %{id: id} = redirected_params(conn)

        facility_dashboard_redir = Routes.facility_dashboard_path(conn, :dashboard, id)
        assert redirected_to(conn) == facility_dashboard_redir

        conn = get(conn, facility_dashboard_redir)
        response = html_response(conn, 200)

        assert response =~ "a été enregistrée avec succés."
      end
    end
end

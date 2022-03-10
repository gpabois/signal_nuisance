defmodule SignalNuisanceWeb.EstablishmentRegistrationControllerTest do
    use SignalNuisanceWeb.ConnCase, async: true

    import SignalNuisance.EnterprisesFixtures

    alias SignalNuisance.Enterprises

    setup :setup_context

    def setup_context(ctx) do
        register_and_log_in_user(ctx)
        |> Map.put(:enterprise, enterprise_fixture(%{}))
    end

    describe "GET /enterprises/:slug/establishments/register" do
        test "renders page if the user has the permission", %{conn: conn, enterprise: enterprise, user: user} do
          Enterprises.set_permissions(user, [manage: :establishments], enterprise)
          conn = get(conn, Routes.establishment_registration_path(conn, :new, enterprise.slug))
          response = html_response(conn, 200)
          assert response =~ "Register an establishment"
        end
    
        test "redirects if user is not logged in", %{enterprise: enterprise} do
          conn = build_conn()
          conn = get(conn, Routes.establishment_registration_path(conn, :new, enterprise.slug))
          assert redirected_to(conn) == Routes.user_session_path(conn, :new)
        end
    end


    describe "POST /enterprises/:slug/establishments/register" do
      @tag :capture_log
      test "registers an establishment", %{conn: _conn} do
      end
    end
end
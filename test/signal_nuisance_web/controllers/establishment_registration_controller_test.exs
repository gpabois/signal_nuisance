defmodule SignalNuisanceWeb.EstablishmentRegistrationControllerTest do
    use SignalNuisanceWeb.ConnCase, async: true

    import SignalNuisance.EstablishmentsFixtures
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

        test "403 if user has not the right permissions", %{conn: conn, enterprise: enterprise} do
          conn = get(conn, Routes.establishment_registration_path(conn, :new, enterprise.slug))
          response = html_response(conn, 403)
          assert response =~ "Unauthorized"
        end
    end


    describe "POST /enterprises/:slug/establishments/register" do
      @tag :capture_log
      test "registers an establishment if the user has the permission", %{conn: conn, enterprise: enterprise, user: user} do
        Enterprises.set_permissions(user, [manage: :establishments], enterprise)

        establishment_params = valid_establishment_attributes(%{})
        slug = Slugy.slugify("#{enterprise.id}-#{establishment_params.name}")

        conn =
          post(conn, Routes.establishment_registration_path(conn, :create, enterprise.slug), %{
            "establishment" => establishment_params
          })
        
        lnk = Routes.establishment_dashboard_path(conn, :show, slug)
        assert redirected_to(conn) == lnk
  
        # Now do a logged in request and assert on the menu
        conn = get(conn, lnk)
        response = html_response(conn, 200)
        assert response =~ establishment_params.name
      end

      test "403 if user has not the right permissions", %{conn: conn, enterprise: enterprise} do
        conn = get(conn, Routes.establishment_registration_path(conn, :new, enterprise.slug))
        establishment_params = valid_establishment_attributes(%{})
        
        conn = post(conn, Routes.establishment_registration_path(conn, :create, enterprise.slug), %{
          "establishment" => establishment_params
        })

        response = html_response(conn, 403)
        assert response =~ "Unauthorized"
      end
    end
end
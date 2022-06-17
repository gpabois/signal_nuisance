defmodule SignalNuisanceWeb.Administration.AdministrationUserControllerTest do
  use SignalNuisanceWeb.ConnCase, async: true

  setup :register_and_log_in_user

  import SignalNuisance.AccountsFixtures
  alias SignalNuisance.Accounts

  alias SignalNuisance.Administration

  defp grant_credentials(user) do
    Administration.add_administrator(user)
    Administration.grant_permissions(user, manage: :users)
  end

  describe "GET /admin/users" do
      test "accéder à la page sans avoir l'autorisation", %{conn: conn} do
        conn = get(conn, Routes.administration_user_path(conn, :index))
        response = html_response(conn, 403)
        assert response =~ "Unauthorized"
      end

      test "accéder à la page avec l'autorisation", %{conn: conn, user: user} do
        grant_credentials(user)
        conn = get(conn, Routes.administration_user_path(conn, :index))
        response = html_response(conn, 200)
        assert response =~ "Liste des utilisateurs"
      end
  end

  describe "GET /admin/users/:id" do
    test "accéder à la page sans avoir l'autorisation", %{conn: conn} do
      user = user_fixture()
      conn = get(conn, Routes.administration_user_path(conn, :show, user))
      response = html_response(conn, 403)
      assert response =~ "Unauthorized"
    end

    test "accéder à la page avec l'autorisation", %{conn: conn, user: user} do
      grant_credentials(user)
      tuser = user_fixture()
      conn = get(conn, Routes.administration_user_path(conn, :show, tuser))
      response = html_response(conn, 200)
      assert response =~ facility.name
    end
  end

  describe "GET /admin/users/:id/delete" do
    test "executer l'action sans avoir l'autorisation", %{conn: conn} do
      user = user_fixture()

      conn = get(conn, Routes.administration_user_path(conn, :delete, user))

      response = html_response(conn, 403)
      assert response =~ "Unauthorized"
    end

    test "executer l'action avec l'autorisation", %{conn: conn, user: user} do
      grant_credentials(user)
      tuser = user()

      conn = get(conn, Routes.administration_user_path(conn, :delete, tuser))
      assert redirected_to(conn) == Routes.administration_user_path(conn, :index)

      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(tuser.id) end
    end
  end
end

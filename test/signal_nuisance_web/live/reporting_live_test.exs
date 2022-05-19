defmodule SignalNuisanceWeb.ReportingLiveTest do
    use SignalNuisanceWeb.ConnCase, async: true
    import Phoenix.LiveViewTest

    alias SignalNuisance.Administration.Authorization.Permission, as: AdminPermission

    import SignalNuisance.ReportingFixtures

    def alert_form_select_category() do
        {:ok, view, html} =  build_conn() |> live("/")
        view |> element("#btn-open-alert-form") |> render_click()
        {view, html}
    end

    def alert_form_main(category) do
        {view, html} = alert_form_select_category()
        view |> element("#alert-form-#{category}-category") |> render_click()
        {view, html}
    end

    setup :register_and_log_in_user

    describe "accéder au tableau d'administration" do
        test "lorsque l'utilisateur n'a pas les droits administrateur, le lien vers le tableau d'administration ne doit pas être affiché", %{user: _user, conn: conn} do
            {:ok, view, _html} =  conn |> live("/")
            refute view |> element("a#link-administration") |> has_element?()
        end

        test "lorsque l'utilisateur a les droits administrateur, le lien vers le tableau d'administration doit être affiché", %{user: user, conn: conn} do
            AdminPermission.grant(user, {:access, :administration}, {})
            {:ok, view, _html} =  conn |> live("/")
            assert view |> element("a#link-administration") |> has_element?()
        end
    end

    describe "afficher les marqueurs de carte" do
        test "quand une installation est située dans la zone d'affiche, la carte doit afficher un marqueur dédié" do
            {:ok, view, _html} =  build_conn() |> live("/")
        end
    end

    describe "faire un signalement (alert) quand on est anonyme" do
        test "cela doit être ouvert via un bouton dédié (#btn-open-alert-form)" do
            {:ok, view, _html} =  build_conn() |> live("/")

            view |> element("#btn-open-alert-form") |> render_click()
            assert view |> element("#alert-form") |> has_element?()
        end

        test "la première étape est de choisir la catégorie du signalement (olfactif, bruit...)" do
            {view, _html} = alert_form_select_category()

            for category <- SignalNuisance.Reporting.AlertType.categories() do
                assert view |> element("#alert-form-#{category}-category") |> has_element?()
            end
        end

        test "une fois la catégorie choisie, le formulaire à proprement s'ouvre" do
            {view, _html} = alert_form_select_category()

            category = SignalNuisance.Reporting.AlertType.categories() |> Enum.random()
            view |> element("#alert-form-#{category}-category") |> render_click()
            assert view |> element("#alert-form-main") |> has_element?()
        end

        test "remplir le formulaire, avec des valeurs valides, la localisation de l'utilisateur est remplie via le hook user-loc-update" do
            alert_type = alert_type_fixture()
            alert_attributes = valid_alert_attributes(%{alert_type_id: alert_type.id})

            {view, _html} = alert_form_main(alert_type.category)

            view |> render_hook("user-loc-update", %{"long" => alert_attributes.loc_long, "lat" => alert_attributes.loc_lat})

            assert view
            |> form("#alert-form-main", %{"alert" => alert_attributes})
            |> render_submit() =~ gettext("Signalement enregistré")
        end

        test "doit renvoyer une erreur, si l'utilisateur n'a pas communiqué sa localisation." do
            alert_type = alert_type_fixture()
            alert_attributes = valid_alert_attributes(%{alert_type_id: alert_type.id})

            {view, _html} = alert_form_main(alert_type.category)

            assert view
            |> form("#alert-form-main", %{"alert" => alert_attributes})
            |> render_submit() =~ gettext("Le signalement ne peut pas être enregistré.")
        end
    end
end

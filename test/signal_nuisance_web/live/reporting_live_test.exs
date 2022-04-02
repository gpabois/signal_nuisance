defmodule SignalNuisanceWeb.ReportingLiveTest do
    use SignalNuisanceWeb.ConnCase, async: true
    import Phoenix.LiveViewTest

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

        test "remplir le formulaire avec des valeurs valides" do
            alert_type = alert_type_fixture()
            alert_attributes = valid_alert_attributes(%{alert_type_id: alert_type.id})

            {view, _html} = alert_form_main(alert_type.category)

            view
            |> form("#alert-form-main", %{"alert" => alert_attributes})
            |> render_submit() =~ "Alert created"
        end
    end
end

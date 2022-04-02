defmodule SignalNuisance.AdministrationTest do
    use SignalNuisance.DataCase

    import SignalNuisance.AccountsFixtures

    alias SignalNuisance.Administration.Authorization.Permission, as: AdminPermission
    alias SignalNuisance.Administration.SecurityPolicy, as: AdminSecPolicy

    describe "SignalNuisance.Administration.SecurityPolicy" do
        test "l'utilisateur doit être autorisé à accéder au panneau administrateur s'il a la permission administrateur {:access, :administration}" do
            user = user_fixture()

            AdminPermission.grant(user, {:access, :administration}, {})

            assert Bodyguard.permit?(AdminSecPolicy, {:access, :view, :administration_dashboard}, user, {})
        end
    end

end

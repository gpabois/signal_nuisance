defmodule SignalNuisance.AdministrationTest do
    use SignalNuisance.DataCase
  
    import SignalNuisance.AccountsFixtures

    alias SignalNuisance.Administration.Authorization.Permission, as: AdminPermission
    alias SignalNuisance.Administration.SecurityPolicy, as: AdminSecPolicy

    describe "SignalNuisance.Administration.SecurityPolicy" do
        test "authorize access to administration dashboard when the user has the admin permission {:access, :administration}" do
            user = user_fixture()

            AdminPermission.grant(user, {:access, :administration}, {})

            assert Bodyguard.permit?(AdminSecPolicy, {:access, :view, :administration_dashboard}, user, {})
        end
    end

end
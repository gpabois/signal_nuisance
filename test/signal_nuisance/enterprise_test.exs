defmodule SignalNuisance.EnterpriseTest do
    use SignalNuisance.DataCase
  
    import SignalNuisance.{EnterprisesFixtures, AccountsFixtures, EstablishmentsFixtures}
    
    alias SignalNuisance.{Enterprise, Establishment, Authorization}
    alias GeoMath.Distance

    describe "create_enterprise/1" do
        test "create an enterprise without name taken" do
            enterprise_attrs = valid_enterprise_attributes()

            {:ok, _enterprise} = Enterprise.create_enterprise(enterprise_attrs)
        end

        test "try and fail to create an enterprise with name taken" do
            enterprise_attrs = valid_enterprise_attributes()

            {:ok, _enterprise}  = Enterprise.create_enterprise(enterprise_attrs)
            {:error, changeset} = Enterprise.create_enterprise(enterprise_attrs)

            assert %{
                slug: ["has already been taken"]
            } = errors_on(changeset)
        end
    end

    describe "get_by_name/1" do
        test "get an enterprise by its name, when no enterprise with this name exists." do
            enterprise_attrs = valid_enterprise_attributes()
            assert nil == Enterprise.get_by_name(enterprise_attrs.name)
        end

        test "get an enterprise by its name, when an enterprise with this name exists" do
            enterprise = enterprise_fixture()
            enterprise_id = enterprise.id

            assert %Enterprise{id: ^enterprise_id} = Enterprise.get_by_name(enterprise.name)
        end
    end

    describe "register_enterprise/2" do
        test "register an enterprise" do
            user = user_fixture()
            enterprise_attrs = valid_enterprise_attributes()

            {:ok, enterprise} = Enterprise.register_enterprise(enterprise_attrs, user)
            assert user in Enterprise.members(enterprise)
        end

        test "register an existing enterprise" do
            user = user_fixture()
            enterprise_attrs = valid_enterprise_attributes()
            
            Enterprise.create_enterprise(enterprise_attrs)

            {:error, changeset} = Enterprise.register_enterprise(enterprise_attrs, user)
            assert %{
                slug: ["has already been taken"]
            } = errors_on(changeset)
        end
    end

    describe "authorization" do
        test "access dashboard when the user is not a member of the enterprise" do
            user        = user_fixture()
            enterprise  = enterprise_fixture()      
            
            refute Authorization.can(user, enterprise: enterprise, access: :dashboard)
        end

        test "access dashboard when the user is a member of the enterprise" do
            user        = user_fixture()
            enterprise  = enterprise_fixture()      
            
            Enterprise.register_member(enterprise, user)
            assert Authorization.can(user, enterprise: enterprise, access: :dashboard)
        end

        test "access production schedule when the user is not a member of the enterprise" do
            user        = user_fixture()
            enterprise  = enterprise_fixture()      
            
            refute Authorization.can(user, enterprise: enterprise, access: :production_schedule)
        end

        test "access production schedule when the user is a member of the enterprise" do
            user        = user_fixture()
            enterprise  = enterprise_fixture()      
            
            Enterprise.register_member(enterprise, user)
            assert Authorization.can(user, enterprise: enterprise, access: :production_schedule)
        end

    end

    describe "manage enterprise member/2" do
        test "register_member/1, members/1, unregister_member/1" do
            user        = user_fixture()
            enterprise  = enterprise_fixture()

            assert user not in Enterprise.members(enterprise)
            
            Enterprise.register_member(enterprise, user)
            assert user in Enterprise.members(enterprise)
            
            Enterprise.unregister_member(enterprise, user)
            assert user not in Enterprise.members(enterprise)
        end

        test "get_by_user/1" do
            user        = user_fixture()
            enterprise  = enterprise_fixture()
            
            assert enterprise not in Enterprise.get_by_user(user)
            Enterprise.register_member(enterprise, user)
            assert enterprise in Enterprise.get_by_user(user)
        end
    end

    describe "manage establishments" do
        test "create_establishment/1" do
            enterprise = enterprise_fixture()
            establishment_attrs = valid_establishment_attributes(%{enterprise_id: enterprise.id})
            assert {:ok, _establishment} = Establishment.create_establishment(establishment_attrs)
        end

        test "get_by_entreprise/1" do
            enterprise = enterprise_fixture()
            establishment = establishment_fixture(%{enterprise_id: enterprise.id})
            
            assert establishment in Establishment.get_by_entreprise(enterprise)
        end

        test "get_nearest/2 when one establishment is in range" do
            enterprise = enterprise_fixture()
            establishment = establishment_fixture(%{enterprise_id: enterprise.id})

            d0 = Distance.km(10)
            d1 = Distance.km(10)
            pt = GeoMath.random_within(establishment.loc, d0)

            assert GeoMath.within?(establishment.loc, pt, d0)
            assert establishment in Establishment.get_nearest(pt, d1)
        end


        test "get_nearest/2 when no establishment is in range" do
            enterprise = enterprise_fixture()
            establishment = establishment_fixture(%{enterprise_id: enterprise.id})

            d0 = Distance.km(10)
            d1 = Distance.km(5)
            pt = GeoMath.random_around(establishment.loc, d0)

            assert GeoMath.away_from?(establishment.loc, pt, d0)
            refute GeoMath.within?(establishment.loc, pt, d1)
            refute establishment in Establishment.get_nearest(pt, d1)
        end
    end
end
  
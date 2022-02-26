defmodule SignalNuisance.EnterpriseTest do
    use SignalNuisance.DataCase

    import SignalNuisance.{EnterprisesFixtures, AccountsFixtures, EstablishmentsFixtures}

    alias SignalNuisance.Enterprises
    alias SignalNuisance.Enterprises.{Enterprise, Establishment}

    alias GeoMath.Distance

    describe "Enterprises.register_enterprise/2" do
        test "register the enterprise when the name is not already taken." do
            user = user_fixture()
            enterprise_attrs = valid_enterprise_attributes()

            {:ok, enterprise} = Enterprises.register_enterprise(enterprise_attrs, user)
            assert Enterprises.is_enterprise_member?(enterprise, user)
        end

        test "register when the name is already taken." do
            user = user_fixture()
            enterprise_attrs = valid_enterprise_attributes()

            Enterprise.create(enterprise_attrs)

            {:error, changeset} = Enterprises.register_enterprise(enterprise_attrs, user)

            assert %{
                slug: ["has already been taken"]
            } = errors_on(changeset)
        end
    end

    describe "Enterprises.get_enterprise_by_name/1" do
        test "get an enterprise by its name, when no enterprise with this name exists." do
            enterprise_attrs = valid_enterprise_attributes()
            assert nil == Enterprises.get_enterprise_by_name(enterprise_attrs.name)
        end

        test "get an enterprise by its name, when an enterprise with this name exists" do
            enterprise = enterprise_fixture()
            enterprise_id = enterprise.id
            assert %Enterprise{id: ^enterprise_id} = Enterprises.get_enterprise_by_name(enterprise.name)
        end
    end

    describe "Enterprises.add_enterprise_member/2" do
        test "Register a member to an existing enterprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture()

            assert :ok = Enterprises.add_enterprise_member(enterprise, user)
            assert Enterprises.is_enterprise_member?(enterprise, user)
        end

        test "Add a member to a non-existing enterprise" do
            user        = user_fixture()

            assert {:error, changeset} = Enterprises.add_enterprise_member(%{id: 100}, user)
            assert %{
                enterprise_id: ["does not exist"]
            } = errors_on(changeset)
        end

        test "Add a non-existing member to an existing enterprise" do
            enterprise  = enterprise_fixture()

            assert {:error, changeset} = Enterprises.add_enterprise_member(enterprise, %{id: 100})
            assert %{
                user_id: ["does not exist"]
            } = errors_on(changeset)
        end
    end

    describe "Enterprises.remove_enterprise_member/2" do
        test "Remove a member from an existing enterprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{}, register: [user: user])

            assert :ok = Enterprises.remove_enterprise_member(enterprise, user)
            refute Enterprises.is_enterprise_member?(enterprise, user)
        end
    end


    describe "Enterprises.set_entity_enterprise_permissions/3" do
        test "Grant enterprise-related permissions to a user" do
            user        = user_fixture()
            enterprise  = enterprise_fixture()

            Enterprises.set_entity_enterprise_permissions enterprise, user, [:access]
            assert Enterprises.has_entity_enterprise_permission?(enterprise, user, [:access])
        end
    end

    describe "Enterprises.set_entity_establishment_permissions/3" do
        test "Grant establishment-related permissions to a user" do
            user = user_fixture()
            establishment = establishment_fixture()

            Enterprises.set_entity_establishment_permissions establishment, user, [:access]
            assert Enterprises.has_entity_establishment_permission?(establishment, user, [:access])
        end
    end

    describe "Enterprises.register_establishment/1" do
        test "register establishment when the name is not already taken." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{}, register: [user: user])

            establishment_attrs = valid_establishment_attributes(%{}, enterprise: enterprise)
            assert {:ok, _} = Enterprises.register_establishment(establishment_attrs, user)
        end

        test "register establishment when the name is taken." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{}, register: [user: user])

            establishment_attrs = valid_establishment_attributes(%{}, enterprise: enterprise)
            Establishment.create(establishment_attrs)

            assert {:error, changeset} = Enterprises.register_establishment(establishment_attrs, user)
            assert %{
                slug: ["has already been taken"]
            } = errors_on(changeset)
        end
    end

    describe "Enterprises.get_establishments_by_enterprise/1" do
        test "when the enterprise has an establishment" do
            enterprise = enterprise_fixture()
            establishment = establishment_fixture(%{}, enterprise: enterprise)
            assert establishment in Enterprises.get_establishments_by_enterprise(enterprise)
        end
    end

    describe "Enterprises.get_nearest_establishments/2" do
        test "get nearest when one establishment is in range" do
            establishment = establishment_fixture()

            d0 = Distance.km(10)
            d1 = Distance.km(9)
            pt = GeoMath.random_within(establishment.loc, d0)

            assert GeoMath.within?(establishment.loc, pt, d0)
            assert establishment in Enterprises.get_nearest_establishments(pt, d1)
        end


        test "get nearest when no establishment is in range" do
            establishment = establishment_fixture()

            d0 = Distance.km(10)
            d1 = Distance.km(5)
            pt = GeoMath.random_around(establishment.loc, d0)

            assert GeoMath.away_from?(establishment.loc, pt, d0)
            refute GeoMath.within?(establishment.loc, pt, d1)
            refute establishment in Enterprises.get_nearest_establishments(pt, d1)
        end
    end
end

defmodule SignalNuisance.EnterpriseTest do
    use SignalNuisance.DataCase

    import SignalNuisance.{FacilitiesFixtures, AccountsFixtures}

    alias SignalNuisance.Facilities
    alias SignalNuisance.Facilities.Facility
    alias SignalNuisance.Facilities.Authorization.Permission

    alias GeoMath.Distance

    describe "Facilities.register/2" do
        test "enregistrer une installation avec des valeurs valides." do
            user = user_fixture()
            attrs = valid_facility_attributes()

            {:ok, facility} = Facilities.register(attrs, user)

            # On doit assurer que l'utilisateur qui enregistre l'installation en est membre.
            assert Facilities.is_member?(facility, user)
            # On doit assurer que l'utilisateur qui enregistre l'installation en a les droits administrateurs.
            assert Permission.has?(user, Permission.by_role(:administrator), facility)
        end

        test "on ne doit pas enregistrer une installation qui a un nom déjà pris." do
            user = user_fixture()
            attrs = valid_facility_attributes()

            {:ok, _facility} = Facility.create(attrs)
            {:error, changeset} = Facilities.register(attrs, user)

            assert %{
                name: ["has already been taken"]
            } = errors_on(changeset)
        end
    end

    describe "Facilities.get_nearest_facilities/2" do
        test "la fonction doit retourner la liste des installations dans un rayon donné." do
            facility = facility_fixture()

            d0 = Distance.km(10)
            d1 = Distance.km(8)
            pt = GeoMath.random_within(facility.loc, d1)

            assert GeoMath.within?(facility.loc, pt, d0)
            assert facility in Facilities.get_nearest_facilities(pt, d1)
        end


        test "la fonction doit retourner une liste vide, si aucune installation ne se trouve dans le rayon donné." do
            facility = facility_fixture()

            d0 = Distance.km(10)
            d1 = Distance.km(5)
            pt = GeoMath.random_around(facility.loc, d0)

            assert GeoMath.away_from?(facility.loc, pt, d0)
            refute GeoMath.within?(facility.loc, pt, d1)
            refute facility in Facilities.get_nearest_facilities(pt, d1)
        end
    end


end
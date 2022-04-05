defmodule SignalNuisance.EnterpriseTest do
    use SignalNuisance.DataCase

    import SignalNuisance.{EnterprisesFixtures, AccountsFixtures, EstablishmentsFixtures}

    alias SignalNuisance.Enterprises
    alias SignalNuisance.Enterprises.{Enterprise, Establishment}
    alias SignalNuisance.Enterprises.Authorization.{EnterprisePermission, EstablishmentPermission}

    alias GeoMath.Distance

    describe "Enterprises.register_enterprise/2" do
        test "enregistrer une entreprise avec des valeurs valides." do
            user = user_fixture()
            enterprise_attrs = valid_enterprise_attributes()

            {:ok, enterprise} = Enterprises.register_enterprise(enterprise_attrs, user)
            assert Enterprises.is_enterprise_member?(enterprise, user)
        end

        test "on ne doit pas enregistrer une entreprise qui a un nom déjà pris." do
            user = user_fixture()
            enterprise_attrs = valid_enterprise_attributes()

            Enterprise.register(enterprise_attrs)

            {:error, changeset} = Enterprises.register_enterprise(enterprise_attrs, user)

            assert %{
                slug: ["has already been taken"]
            } = errors_on(changeset)
        end

        test "un utilisateur qui enregistre une entreprise doit avoir les droits d'administrateur de l'entreprise." do
            user = user_fixture()
            enterprise_attrs = valid_enterprise_attributes()

            {:ok, enterprise} = Enterprises.register_enterprise(enterprise_attrs, user)
            assert EnterprisePermission.has?(user, EnterprisePermission.by_role(:administrator), enterprise)
        end
    end

    describe "Enterprises.get_enterprise_by_name/1" do
        test "la fonction doit la valeur nil, lorsqu'aucune entreprise avec ce nom est enregistré." do
            enterprise_attrs = valid_enterprise_attributes()
            assert nil == Enterprises.get_enterprise_by_name(enterprise_attrs.name)
        end

        test "la fonction doit retourner l'entreprise, lorsqu'une entreprise avec ce nom est enregistré." do
            enterprise = enterprise_fixture()
            enterprise_id = enterprise.id
            assert %Enterprise{id: ^enterprise_id} = Enterprises.get_enterprise_by_name(enterprise.name)
        end
    end

    describe "Enterprises.add_enterprise_member/2" do
        test "la fonction doit enregistrer un nouveau membre dans l'entreprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture()

            assert :ok = Enterprises.add_enterprise_member(enterprise, user)
            assert Enterprises.is_enterprise_member?(enterprise, user)
        end

        test "enregistrer un nouveau membre dans l'entreprise doit lui donner les permissions liées à un employé." do
            user        = user_fixture()
            enterprise  = enterprise_fixture()

            Enterprises.add_enterprise_member(enterprise, user)
            assert EnterprisePermission.has?(user, EnterprisePermission.by_role(:employee), enterprise)
        end

        test "la fonction doit retourner une erreur lorsqu'on enregistre un utilisateur dans une entreprise qui n'existe pas." do
            user        = user_fixture()

            assert {:error, changeset} = Enterprises.add_enterprise_member(%{id: 100}, user)
            assert %{
                enterprise_id: ["does not exist"]
            } = errors_on(changeset)
        end

        test "la fonction doit retourner une erreur lorsqu'on enregistre un utilisateur qui n'existe pas dans une entreprise." do
            enterprise  = enterprise_fixture()

            assert {:error, changeset} = Enterprises.add_enterprise_member(enterprise, %{id: 100})
            assert %{
                user_id: ["does not exist"]
            } = errors_on(changeset)
        end
    end

    describe "Enterprises.remove_enterprise_member/2" do
        test "la fonction doit retirer un membre d'une entreprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{}, register: user)

            assert :ok = Enterprises.remove_enterprise_member(enterprise, user)
            refute Enterprises.is_enterprise_member?(enterprise, user)
        end
    end


    describe "Enterprises.set_permissions/3" do
        test "la fonction doit donner des permissions, relatives à une entreprise, à un utilisateur." do
            user        = user_fixture()
            enterprise  = enterprise_fixture()

            Enterprises.set_permissions user, [:access], enterprise
            assert Enterprises.has_permissions?(user, [:access], enterprise)
        end

        test "la fonction doit donner des permissions, relatives à un établissement, à un utilisateur." do
            user = user_fixture()
            establishment = establishment_fixture()

            Enterprises.set_permissions user, [:access], establishment
            assert Enterprises.has_permissions?(user, [:access], establishment)
        end
    end


    describe "Enterprises.register_establishment/1" do
        test "la fonction doit enregistrer un établissement." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{}, register: user)

            establishment_attrs = valid_establishment_attributes(%{}, enterprise: enterprise)
            assert {:ok, _} = Enterprises.register_establishment(establishment_attrs, user)
        end

        test "la fonction doit retourner une erreur si le nom est déjà pris par un autre établissement." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{}, register: user)

            establishment_attrs = valid_establishment_attributes(%{}, enterprise: enterprise)
            Establishment.register(establishment_attrs)

            assert {:error, changeset} = Enterprises.register_establishment(establishment_attrs, user)
            assert %{
                slug: ["has already been taken"]
            } = errors_on(changeset)
        end
    end

    describe "Enterprises.get_establishments_by_enterprise/1" do
        test "la fonction doit retourner les établissements liés à une entreprise." do
            enterprise = enterprise_fixture()
            establishment = establishment_fixture(%{}, enterprise: enterprise)
            assert establishment in Enterprises.get_establishments_by_enterprise(enterprise)
        end
    end

    describe "Enterprises.get_nearest_establishments/2" do
        test "la fonction doit retourner la liste des établissements dans un rayon donné." do
            establishment = establishment_fixture()

            d0 = Distance.km(10)
            d1 = Distance.km(8)
            pt = GeoMath.random_within(establishment.loc, d1)

            assert GeoMath.within?(establishment.loc, pt, d0)
            assert establishment in Enterprises.get_nearest_establishments(pt, d1)
        end


        test "la fonction doit retourner une liste vide, si aucun établissement ne se trouve dans le rayon donné." do
            establishment = establishment_fixture()

            d0 = Distance.km(10)
            d1 = Distance.km(5)
            pt = GeoMath.random_around(establishment.loc, d0)

            assert GeoMath.away_from?(establishment.loc, pt, d0)
            refute GeoMath.within?(establishment.loc, pt, d1)
            refute establishment in Enterprises.get_nearest_establishments(pt, d1)
        end
    end

    describe "Enterprises.get_establishments_in_area/2" do
        test "la fonction doit retourner les établissements qui se situent dans une zone définie par un rectangle." do
            establishment = establishment_fixture()

            d0 = Distance.km(10)
            d1 = Distance.km(9)
            pt = GeoMath.random_within(establishment.loc, d1)

            assert GeoMath.within?(establishment.loc, pt, d0)

            {ll, ur} = GeoMath.bounding_box(pt, d1)

            assert establishment in Enterprises.get_establishments_in_area(ll, ur)
        end

    end

    describe "SignalNuisance.Enterprises.SecurityPolicy::Enterprise" do
        test "l'utilisateur ne doit pas être autorisé à accéder au tableau de bord d'une entreprise, s'il n'est pas membre de l'entreprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{})

            refute Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:access, :view, :dashboard}, user, enterprise)
        end
        test "l'utilisateur doit être autorisé à accéder au tableau de bord d'une entreprise, s'il est membre de l'entreprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{})

            Enterprises.add_enterprise_member(enterprise, user)
            assert Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:access, :view, :dashboard}, user, enterprise)
        end

        test "l'utilisateur ne doit pas être autorisé à accéder à la gestion des membres de l'entreprise, s'il n'a pas la permission {:manage, :members} relative à l'entreprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{})

            refute Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:access, :view, :member_management}, user, enterprise)
        end

        test "l'utilisateur doit être autorisé à accéder à la gestion des membres de l'entreprise, s'il a la permission {:manage, :members} relative à l'entreprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{})

            EnterprisePermission.grant(user, [manage: :members], enterprise)
            assert Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:access, :view, :member_management}, user, enterprise)
        end

        test "l'utilisateur ne doit pas être autorisé à accéder à la gestion des paramètres généraux, s'il n'a pas la permission {:manage, :enterprise} relative à l'entreprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{})

            refute Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:access, :view, :general_settings}, user, enterprise)
        end

        test "l'utilisateur doit être autorisé à accéder à la gestion des paramètres généraux, s'il a la permission {:manage, :enterprise} relative à l'entreprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{})

            EnterprisePermission.grant(user, [manage: :enterprise], enterprise)
            assert Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:access, :view, :general_settings}, user, enterprise)
        end

        test "l'utilisateur ne doit pas être autorisé à accéder au formulaire d'enregistrement d'un établissement, s'il n'a pas la permission {:manage, :establishments} relative à l'entreprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{})

            refute Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:access, :view, :register_establishment}, user, enterprise)
        end

        test "l'utilisateur doit être autorisé à accéder au formulaire d'enregistrement d'un établissement, s'il a pas la permission {:manage, :establishments} relative à l'entreprise" do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{})

            EnterprisePermission.grant(user, [manage: :establishments], enterprise)
            assert Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:access, :view, :register_establishment}, user, enterprise)
        end

        test "l'utilisateur doit être autorisé à enregistrer un établissement, s'il a la permission {:manage, :establishments} relative à l'entreprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{})

            EnterprisePermission.grant(user, [manage: :establishments], enterprise)
            assert Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, :register_establishment, user, enterprise)
        end

        test "l'utilisateur ne doit pas être autorisé à enregistrer un établissement, s'il n'a la permission {:manage, :establishments} relative à l'entreprise" do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{})

            refute Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, :register_establishment, user, enterprise)
        end

        test "l'utilisateur ne doit pas être autorisé à modifier les paramètres généraux d'une entreprise, s'il n'a pas la permission {:manage, :enterprise} relative à l'entreprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{})

            refute Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:update, :general_settings}, user, enterprise)
        end

        test "l'utilisateur doit être autorisé à modifier les paramètres généraux d'une entreprise, s'il a la permission {:manage, :enterprise} relative à l'entreprise." do
            user        = user_fixture()
            enterprise  = enterprise_fixture(%{})

            EnterprisePermission.grant(user, [manage: :enterprise], enterprise)
            assert Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:update, :general_settings}, user, enterprise)
        end

        test "l'utilisateur ne doit pas être autorisé à modifier les permissions, relatives à l'entreprise, d'un membre, s'il n'a pas la permission {:manage, :members} relative à l'entreprise." do
            user        = user_fixture()
            member      = user_fixture()
            enterprise  = enterprise_fixture(%{})

            refute Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:assign_permissions, enterprise}, user, member)
        end

        test "l'utilisateur doit être autorisé à modifier les permissions, relatives à l'entreprise, d'un membre, s'il a la permission {:manage, :members} relative à l'entreprise." do
            user        = user_fixture()
            member      = user_fixture()
            enterprise  = enterprise_fixture(%{})

            EnterprisePermission.grant(user, [manage: :members], enterprise)
            assert Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:assign_permissions, enterprise}, user, member)
        end

        test "l'utilisateur ne doit pas être autorisé à ajouter un membre à l'entreprise, s'il n'a pas la permission {:manage, :members} relative à l'entreprise" do
            user        = user_fixture()
            member      = user_fixture()
            enterprise  = enterprise_fixture(%{})

            refute Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:add_member, enterprise}, user, member)
        end

        test "l'utilisateur doit être autorisé à ajouter un membre à l'entreprise, s'il a la permission {:manage, :members} relative à l'entreprise" do
            user        = user_fixture()
            member      = user_fixture()
            enterprise  = enterprise_fixture(%{})

            EnterprisePermission.grant(user, [manage: :members], enterprise)
            assert Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:add_member, enterprise}, user, member)
        end

        test "l'utilisateur ne doit pas être autorisé à retirer un membre à l'entreprise, s'il n'a pas la permission {:manage, :members} relative à l'entreprise" do
            user        = user_fixture()
            member      = user_fixture()
            enterprise  = enterprise_fixture(%{})

            refute Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:add_member, enterprise}, user, member)
        end

        test "l'utilisateur doit être autorisé à retirer un membre à l'entreprise, s'il a la permission {:manage, :members} relative à l'entreprise" do
            user        = user_fixture()
            member      = user_fixture()
            enterprise  = enterprise_fixture(%{})

            EnterprisePermission.grant(user, [manage: :members], enterprise)
            assert Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:remove_member, enterprise}, user, member)
        end
    end

    describe "SignalNuisance.Enterprises.SecurityPolicy::Establishment" do
        test "l'utilisateur ne doit pas être autorisé à accéder au tableau de bord de l'établissement, s'il n'a pas la permission {:access, :common} relative à l'établissement." do
            user        = user_fixture()
            establishment = establishment_fixture()

            refute Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:access, :view, :dashboard}, user, establishment)
        end

        test "l'utilisateur doit être autorisé à accéder au tableau de bord de l'établissement, s'il a la permission {:access, :common} relative à l'étalissement." do
            user        = user_fixture()
            establishment = establishment_fixture()

            EstablishmentPermission.grant(user, [access: :common], establishment)
            assert Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:access, :view, :dashboard}, user, establishment)
        end

        test "l'utilisateur ne doit pas être autorisé à diffuser au public des messages, s'il n'a pas la permission {:manage, :communication] relative à l'établissement." do
            user = user_fixture()
            establishment = establishment_fixture()

            refute Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:broadcast, :message, establishment}, user, %{})
        end
        test "l'utilisateur doit être autorisé à diffuser au public des messages, s'il a la permission {:manage, :communication} relative à l'établissement." do
            user = user_fixture()
            establishment = establishment_fixture()

            EstablishmentPermission.grant(user, [manage: :communication], establishment)
            assert Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:broadcast, :message, establishment}, user, %{})
        end
        test "l'utilisateur ne doit pas être autorisé, au nom de l'établissement, à répondre à un signalement, si il n'a pas la permission {:manage, :communication} relative à l'établissement." do
            user = user_fixture()
            establishment = establishment_fixture()

            refute Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:reply, :alert, establishment}, user, %{})
        end
        test "l'utilisateur doit être autorisé, au nom de l'établissement, à répondre à un signalement, s'il a la permission {:manage, :communication} relative à l'établissement." do
            user = user_fixture()
            establishment = establishment_fixture()

            EstablishmentPermission.grant(user, [manage: :communication], establishment)
            assert Bodyguard.permit?(SignalNuisance.Enterprises.SecurityPolicy, {:reply, :alert, establishment}, user, %{})
        end
    end
end

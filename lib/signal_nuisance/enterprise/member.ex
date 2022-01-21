defmodule SignalNuisance.Enterprise.Member do
    use Ecto.Schema

    import Ecto.Query
    import Ecto.Changeset

    alias SignalNuisance.Repo
    alias SignalNuisance.Enterprise
    alias SignalNuisance.Accounts.User

    schema "enterprise_members" do
      belongs_to :enterprise, Enterprise
      belongs_to :user, User
    end

    def registration_changeset(member, attrs) do 
      member
      |> cast(attrs, [:user_id, :enterprise_id])
       |> validate_required([:user_id, :enterprise_id])
    end
  
    def add(enterprise, user) do
      %__MODULE__{}
      |> registration_changeset(%{user_id: user.id, enterprise_id: enterprise.id})
      |> Repo.insert
    end

    def get_by_enterprise(enterprise) do
        from(
            m in __MODULE__, 
            where: m.enterprise_id == ^enterprise.id
        ) |> Repo.all |> Repo.preload(:user)
    end

    def is_member(enterprise, user) do
      from(
        m in __MODULE__, 
        where: m.enterprise_id == ^enterprise.id,
        where: m.user_id == ^user.id
      ) |> Repo.one != nil
    end

    def remove(enterprise, user) do
        from(
            m in __MODULE__, 
            where: m.user_id == ^user.id, 
            where: m.enterprise_id == ^enterprise.id
        ) |> Repo.delete_all
    end
  end
  
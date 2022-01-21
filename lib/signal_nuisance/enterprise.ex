defmodule SignalNuisance.Enterprise do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias SignalNuisance.Repo
  alias SignalNuisance.Enterprise.Member

  schema "enterprises" do
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(enterprise, attrs) do
    enterprise
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
  end

  @doc false
  defp creation_changeset(enterprise, attrs) do 
    enterprise
    |> cast(attrs, [:name, :slug])
    |> unique_constraint(:name, name: :enterprise_name_unique_index)
    |> unique_constraint(:slug, name: :enterprise_slug_unique_index)
    |> validate_required([:name, :slug])
  end

  @doc """
    Get an enterprise by its name
  """
  def get_by_name(name) do
    from(
      e in __MODULE__,
      where: e.name == ^name
    ) |> Repo.one()
  end

  def get_by_user(user) do
    from(
      e in __MODULE__,
      join: m in Member,
      on: m.enterprise_id == e.id,
      where: m.user_id == ^user.id
    ) |> Repo.all
  end

  @doc """
    Create an enterprise
  """
  def create_enterprise(attrs) do
    %__MODULE__{}
    |> creation_changeset(attrs)
    |> Repo.insert
  end

  @doc """
    Register an enterprise, and add the user as its member
  """
  def register_enterprise(attrs, %SignalNuisance.Accounts.User{} = user) do
    Repo.transaction fn ->
      with {:ok, enterprise} <- create_enterprise(attrs),
           {:ok, _}          <- register_member(enterprise, user) 
      do
        enterprise
      else
        {:error, error} -> Repo.rollback(error)
      end
    end
  end
  
  _ = """
    Members-related methods (register, unregister, list, ...)
  """

  @doc """
    Register a member in the enterprise
  """
  def register_member(enterprise, user) do
    enterprise 
    |> Member.add(user)
  end

  @doc """
    Remove a member from the enterprise
  """
  def unregister_member(enterprise, user) do
    enterprise
    |> Member.remove(user)
  end

  @doc """
    Get all members of an enterprise
  """
  def members(enterprise) do
    enterprise
    |> Member.get_by_enterprise()
    |> Enum.map(fn (m) -> m.user end)
  end

  def is_member(enterprise, user) do
    enterprise
    |> Member.is_member(user)
  end
  
end

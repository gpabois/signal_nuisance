defmodule SignalNuisance.Enterprises.Enterprise do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  import Slugy

  alias SignalNuisance.Repo
  alias SignalNuisance.Enterprise.Member

  schema "enterprises" do
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def registration_changeset(enterprise, attrs) do 
    enterprise
    |> cast(attrs, [:name])
    |> slugify(:name)
    |> unique_constraint(:name, name: :enterprise_name_unique_index)
    |> unique_constraint(:slug, name: :enterprise_slug_unique_index)
    |> validate_required([:name, :slug])
  end

  @doc """
    Get an enterprise by its slug
  """
  def get_by_slug(slug) do
    from(
      e in __MODULE__,
      where: e.slug == ^slug
    ) |> Repo.one()
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

  def get_by_id(id) do
    case from(
      e in __MODULE__,
      where: e.id == ^id
    ) |> Repo.one() do
      nil -> {:error, :not_found}
      enterprise -> {:ok, enterprise}
    end
  end

  @doc """
    Get the enterprises which user is a member.
  """
  def get_by_member(user) do
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
  def register(attrs) do
    %__MODULE__{}
    |> registration_changeset(attrs)
    |> Repo.insert
  end
  
end

defmodule SignalNuisance.Reporting.AlertType do
    use Ecto.Schema

    import Ecto.Changeset
    import Ecto.Query

    alias SignalNuisance.Repo
    
    schema "alert_types" do      
        field :category, :string
        field :label, :string
        field :description, :string
    end

    @doc false
    def creation_changeset(%__MODULE__{} = alert_type, attrs) do 
        alert_type
        |> cast(attrs, [:category, :label, :description])
        |> validate_required([:category, :label, :description])
    end

    def create(attrs) do
        %__MODULE__{} 
        |> creation_changeset(attrs)
        |> Repo.insert()
    end

    def get_by_category(category) do
        from(at in __MODULE__, where: at.category == ^category) |> Repo.all()
    end

    def all() do
        from(at in __MODULE__) |> Repo.all()
    end

    def all(lang) do
        query = from at in __MODULE__,
            left_join: at_tl in SignalNuisance.Reporting.AlertTypeTranslation,
            on: at_tl.alert_type_id == at.id,
            where: at_tl.language_code == ^lang,
            select: {at, at_tl}

        query |> Repo.all()
    end

    def get_by_category(category, lang) do
        query = from at in __MODULE__,
            where: at.category == ^category,
            left_join: at_tl in SignalNuisance.Reporting.AlertTypeTranslation,
            on: at_tl.alert_type_id == at.id,
            where: at_tl.language_code == ^lang,
            select: {at, at_tl}

        query |> Repo.all()
    end
end
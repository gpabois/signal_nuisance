defmodule SignalNuisance.Reporting.AlertType do
    use Ecto.Schema

    import Ecto.Changeset
    import Ecto.Query

    alias SignalNuisance.Repo
    
    @valid_categories ["smell", "noise"]

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
        |> validate_inclusion(:category, @valid_categories)
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

    def all(locale) do
        __MODULE__
        |> join(:left, [at], tl in SignalNuisance.Reporting.AlertTypeTranslation,
            on: at.id == tl.alert_type_id and tl.language_code == ^locale
        )
        |> select_merge([at, tl], map(tl, [:label, :description])) 
        |> Repo.all()
    end

    def get_by_category(category, locale) do
        __MODULE__
        |> where([at], at.category == ^category)
        |> join(:left, [at], tl in SignalNuisance.Reporting.AlertTypeTranslation,
            on: at.id == tl.alert_type_id and tl.language_code == ^locale
        )
        |> select_merge([at, tl], map(tl, [:label, :description])) 
        |> Repo.all()
    end
end
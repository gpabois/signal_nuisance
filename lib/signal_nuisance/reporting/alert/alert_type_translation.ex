defmodule SignalNuisance.Reporting.AlertTypeTranslation do
    use Ecto.Schema

    import Ecto.Changeset
    import Ecto.Query

    alias SignalNuisance.Repo

    schema "alert_types_translations" do
        belongs_to :alert_type,  SignalNuisance.Reporting.AlertType

        field :language_code, :string
        field :label, :string
        field :description, :string
    end

    def update_changeset(%__MODULE__{} = alert_type_tl, attrs \\ %{}) do
        alert_type_tl
        |> cast(attrs, [:label, :description])        
    end

    @doc false
    def creation_changeset(%__MODULE__{} = alert_type_tl, attrs \\ %{}) do 
        alert_type_tl
        |> cast(attrs, [:alert_type_id, :language_code, :label, :description])
        |> unique_constraint(:label)
        |> foreign_key_constraint(:alert_type_id)
        |> validate_required([:alert_type_id, :language_code, :label, :description])
    end

    def create(attr) do
        %__MODULE__{} 
        |> creation_changeset(attr)
        |> Repo.insert()
    end

end
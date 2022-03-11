defmodule SignalNuisance.EstablishmentsFixtures do
    @moduledoc """
    This module defines test helpers for creating
    entities via the `SignalNuisance.Enterprise` context.
    """
  
    alias SignalNuisance.EnterprisesFixtures 
    alias SignalNuisance.Enterprises.Establishment
    alias SignalNuisance.Enterprises

    def unique_name, do: "establishment_#{System.unique_integer()}"
    def unique_slug, do: Slug.slugify(unique_name())
    def unique_loc, do: Geo.Fixtures.random_point()
  
    def valid_establishment_attributes(attrs \\ %{}, opts \\ []) do
      attrs = case Keyword.fetch(opts, :enterprise) do
        {:ok, enterprise} ->
        attrs |> Map.put(:enterprise_id, enterprise.id)
        _ ->
        enterprise = EnterprisesFixtures.enterprise_fixture()
        attrs |> Map.put(:enterprise_id, enterprise.id)
      end

      Enum.into(attrs, %{
        name: unique_name(),
        loc: unique_loc()
      })
    end
  
    def establishment_fixture(attrs \\ %{}, opts \\ []) do
      case Keyword.fetch(opts, :register) do
        {:ok, args} -> 
          {:ok, establishment} = 
          attrs
          |> valid_establishment_attributes(opts)
          |> Enterprises.register_establishment(Keyword.fetch!(args, :user))

          establishment
        _ ->
      {:ok, establishment} =
        attrs
        |> valid_establishment_attributes(opts)
        |> Establishment.register()
  
        establishment
      end
    end

  end
  
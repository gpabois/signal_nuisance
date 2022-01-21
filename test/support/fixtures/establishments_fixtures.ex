defmodule SignalNuisance.EstablishmentsFixtures do
    @moduledoc """
    This module defines test helpers for creating
    entities via the `SignalNuisance.Enterprise` context.
    """
  
    def unique_name, do: "establishment_#{System.unique_integer()}"
    def unique_slug, do: Slug.slugify(unique_name())
    def unique_loc, do: Geo.Fixtures.random_point()
  
    def valid_establishment_attributes(attrs \\ %{}) do
      Enum.into(attrs, %{
        name: unique_name(),
        slug: unique_slug(),
        loc: unique_loc()
      })
    end
  
    def establishment_fixture(attrs \\ %{}) do
      {:ok, establishment} =
        attrs
        |> valid_establishment_attributes()
        |> SignalNuisance.Establishment.create_establishment()
  
        establishment
    end

  end
  
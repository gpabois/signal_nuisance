defmodule SignalNuisance.EnterprisesFixtures do
    @moduledoc """
    This module defines test helpers for creating
    entities via the `SignalNuisance.Enterprise` context.
    """
  
    def unique_name, do: "enterprise_#{System.unique_integer()}"
    def unique_slug, do: Slug.slugify(unique_name())
  
    def valid_enterprise_attributes(attrs \\ %{}) do
      Enum.into(attrs, %{
        name: unique_name(),
        slug: unique_slug()
      })
    end
  
    def enterprise_fixture(attrs \\ %{}) do
      {:ok, enterprise} =
        attrs
        |> valid_enterprise_attributes()
        |> SignalNuisance.Enterprise.create_enterprise()
  
        enterprise
    end

  end
  
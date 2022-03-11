defmodule SignalNuisance.EnterprisesFixtures do
    @moduledoc """
    This module defines test helpers for creating
    entities via the `SignalNuisance.Enterprise` context.
    """

    alias SignalNuisance.Enterprises.Enterprise
    alias SignalNuisance.Enterprises

    def unique_name, do: "enterprise_#{System.unique_integer()}"
    def unique_slug, do: Slug.slugify(unique_name())

    def valid_enterprise_attributes(attrs \\ %{}) do
      Enum.into(attrs, %{
        name: unique_name()
      })
    end

    def enterprise_fixture(attrs \\ %{}, opts \\ []) do
      case Keyword.fetch(opts, :register) do
        {:ok, user} ->
          {:ok, enterprise} =
          attrs
          |> valid_enterprise_attributes()
          |> Enterprises.register_enterprise(user)
          enterprise
        _ ->
      {:ok, enterprise} =
        attrs
        |> valid_enterprise_attributes()
        |> Enterprise.register()

        enterprise
      end
    end

  end

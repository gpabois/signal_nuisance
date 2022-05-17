defmodule SignalNuisance.FacilitiesFixtures do
    @moduledoc """
    This module defines test helpers for creating
    entities via the `SignalNuisance.Enterprise` context.
    """

    alias SignalNuisance.Facilities.Facility
    alias SignalNuisance.Facilities

    def unique_name, do: "facility_#{System.unique_integer()}"
    def unique_loc, do: Geo.Fixtures.random_point()
  
    def valid_facility_attributes(attrs \\ %{}, opts \\ []) do
      Enum.into(attrs, %{
        name: unique_name(),
        loc: unique_loc()
      })
    end
  
    def facility_fixture(attrs \\ %{}, opts \\ []) do
      case Keyword.fetch(opts, :register) do
        {:ok, args} -> 
          {:ok, facility} = 
          attrs
          |> valid_facility_attributes(opts)
          |> Facilities.register(Keyword.fetch!(args, :user))

          facility
        _ ->
      {:ok, facility} =
        attrs
        |> valid_facility_attributes(opts)
        |> Facility.create
  
        establishment
      end
    end

  end
  
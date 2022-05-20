defmodule SignalNuisance.FacilitiesFixtures do
    @moduledoc """
    This module defines test helpers for creating
    entities via the `SignalNuisance.Enterprise` context.
    """

    alias SignalNuisance.Facilities.Facility
    alias SignalNuisance.Facilities

    def unique_name, do: "facility_#{System.unique_integer()}"
    def unique_loc, do: Geo.Fixtures.random_point()
  
    def valid_facility_attributes(attrs \\ %{}) do
      Enum.into(attrs, %{
        name: unique_name(),
        loc: unique_loc()
      })
    end

    def valid_facility_form_attributes(attrs \\ %{}) do
      %{coordinates: {lat, long}} = unique_loc()
      Enum.into(attrs, %{
        name: unique_name(),
        lat: lat,
        long: long
      })
    end
  
    def facility_fixture() do
      facility_fixture(%{})
    end

    def facility_fixture(attrs, opts \\ []) do
      case Keyword.fetch(opts, :register) do
        {:ok, args} -> 
          {:ok, facility} = 
          attrs
          |> valid_facility_attributes()
          |> Facilities.register(Keyword.fetch!(args, :user))

          facility
        _ ->
      {:ok, facility} =
        attrs
        |> valid_facility_attributes()
        |> Facility.create
  
        facility
      end
    end

  end
  
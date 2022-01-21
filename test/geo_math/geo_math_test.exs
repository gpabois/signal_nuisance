defmodule GeoMath.Tests do 
    use ExUnit.Case, async: true
    
    def float_eq(a, b, err) do
        a <= b + err and b - err <= a
    end

    describe "test distance" do
        test "distance/3" do
            ptA = %Geo.Point{coordinates: {48.85, 2.35}, srid: 4326}
            ptB = %Geo.Point{coordinates: {40.7166666667, -74}, srid: 4326}
            d = GeoMath.Distance.km(5836.701859058802)

            assert GeoMath.distance(ptA, ptB, :km) == d
        end
    end

    describe "test random" do
        test "random_within/2" do
            ptA = %Geo.Point{coordinates: {48.85, 2.35}, srid: 4326}
            r = GeoMath.Distance.km(10)
            eps = 0.001

            ptB = GeoMath.random_within(ptA, r)
            assert GeoMath.within?(ptA, ptB, r, eps)         
        end
    end
  end
  
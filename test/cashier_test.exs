defmodule CashierTest do
  use ExUnit.Case
  alias Cashier.Core.Product
  doctest Cashier

  describe "Whole transaction" do
    setup do
      green_tea = Product.find("GR1")
      strawberry = Product.find("SR1")
      coffee = Product.find("CF1")

      pricing_rules = %{
        "GR1" => [Cashier.Core.PricingRule.BOGO],
        "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff],
        "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice]
      }

      {:ok,
       green_tea: green_tea, strawberry: strawberry, coffee: coffee, pricing_rules: pricing_rules}
    end

    test "add green tea, strawberry, green tea, green tea, coffee in basket, total of the basket returns £22.45",
         %{
           green_tea: green_tea,
           strawberry: strawberry,
           coffee: coffee,
           pricing_rules: pricing_rules
         } do
      result =
        pricing_rules
        |> Cashier.new()
        |> Cashier.scan(green_tea)
        |> Cashier.scan(strawberry)
        |> Cashier.scan(green_tea)
        |> Cashier.scan(green_tea)
        |> Cashier.scan(coffee)
        |> Cashier.total()

      assert "£22.45" == result
    end

    test "add green tea, green tea in basket, total of the basket returns £3.11", %{
      green_tea: green_tea,
      pricing_rules: pricing_rules
    } do
      result =
        pricing_rules
        |> Cashier.new()
        |> Cashier.scan(green_tea)
        |> Cashier.scan(green_tea)
        |> Cashier.total()

      assert "£3.11" == result
    end

    test "add strawberry, strawberry, green tea, strawberry in basket, total of the basket returns £16.61",
         %{green_tea: green_tea, strawberry: strawberry, pricing_rules: pricing_rules} do
      result =
        pricing_rules
        |> Cashier.new()
        |> Cashier.scan(strawberry)
        |> Cashier.scan(strawberry)
        |> Cashier.scan(green_tea)
        |> Cashier.scan(strawberry)
        |> Cashier.total()

      assert "£16.61" == result
    end

    test "add green tea, coffee, strawberry, coffee, coffee in basket, total of the basket returns £30.57",
         %{
           green_tea: green_tea,
           strawberry: strawberry,
           coffee: coffee,
           pricing_rules: pricing_rules
         } do
      result =
        pricing_rules
        |> Cashier.new()
        |> Cashier.scan(green_tea)
        |> Cashier.scan(coffee)
        |> Cashier.scan(strawberry)
        |> Cashier.scan(coffee)
        |> Cashier.scan(coffee)
        |> Cashier.total()

      assert "£30.57" == result
    end
  end
end

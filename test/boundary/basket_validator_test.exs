defmodule Cashier.Boundary.BasketValidatorTest do
  use ExUnit.Case
  alias Cashier.Boundary.BasketValidator
  alias Cashier.Core.Basket

  describe "BasketValidator.errors/1" do
    test "nil as basket returns error tuple" do
      assert [{:error, _}] = BasketValidator.errors(nil)
    end

    test "empty list as basket returns error tuple" do
      assert [{:error, _}] = BasketValidator.errors([])
    end

    test "empty map as basket returns error tuple" do
      assert [{:error, _}] = BasketValidator.errors(%{})
    end

    test "map with Basket fields an total as basket returns error tuple" do
      assert [{:error, _}] =
               BasketValidator.errors(%{
                 uuid: UUID.uuid4(),
                 products: [],
                 total: %Money{amount: 0, currency: :GBP},
                 pricing_rules: %{}
               })
    end

    test "Basket with pricing rules field as nil returns error tuple" do
      assert [{:pricing_rules, _}] =
               BasketValidator.errors(%Basket{
                 uuid: UUID.uuid4(),
                 products: [],
                 total: %Money{amount: 0, currency: :GBP},
                 pricing_rules: nil
               })
    end

    test "Basket with pricing rules field as empty list returns error tuple" do
      assert [{:error, _}] =
               BasketValidator.errors(%{
                 uuid: UUID.uuid4(),
                 products: [],
                 total: %Money{amount: 0, currency: :GBP},
                 pricing_rules: []
               })
    end

    test "Basket with pricing rules field is missing returns error tuple" do
      assert [{:error, _}] =
               BasketValidator.errors(%{
                 uuid: UUID.uuid4(),
                 products: [],
                 total: %Money{amount: 0, currency: :GBP}
               })
    end

    test "BAsket with empty pricing rules map returns ok" do
      assert :ok = BasketValidator.errors(%Basket{pricing_rules: %{}})
    end

    test "Basket with wrong pricing rules map returns ok" do
      pricing_rules = %{
        "GR1" => [Cashier.Core.PricingRule.UNKNOWN],
        "SR1" => [Cashier.Core.PricingRule.UNKNOWN],
        "CF1" => [Cashier.Core.PricingRule.UNKNOWN]
      }

      assert [{:pricing_rules, _}] = BasketValidator.errors(%Basket{pricing_rules: pricing_rules})
    end

    test "Basket with pricing rules map returns ok" do
      pricing_rules = %{
        "GR1" => [Cashier.Core.PricingRule.BOGO],
        "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff],
        "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice]
      }

      assert :ok = BasketValidator.errors(%Basket{pricing_rules: pricing_rules})
    end
  end
end

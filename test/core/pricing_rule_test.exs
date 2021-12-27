defmodule Cashier.Core.PricingRuleTest do
  use ExUnit.Case
  alias Cashier.Core.{Basket, PricingRule, Product}

  setup do
    green_tea = Product.find("GR1")
    {:ok, green_tea: green_tea}
  end

  describe "PricingRule.reduce/1" do
    test "empty basket do not reduce price" do
      basket = %Basket{}
      assert basket.total == PricingRule.reduce(basket).total
    end

    test "basket with one green tea and with out pricing rules do not reduce price", %{
      green_tea: green_tea
    } do
      basket = %Basket{products: [green_tea], total: green_tea.price}
      assert basket.total == PricingRule.reduce(basket).total
    end

    test "basket with two green tea's and with out pricing rules do not reduce price", %{
      green_tea: green_tea
    } do
      total = Money.multiply(green_tea.price, 2)
      basket = %Basket{products: [green_tea, green_tea], total: total}
      assert basket.total == PricingRule.reduce(basket).total
    end

    test "basket with three green tea's and with out pricing rules do not reduce price", %{
      green_tea: green_tea
    } do
      total = Money.multiply(green_tea.price, 3)
      basket = %Basket{products: [green_tea, green_tea, green_tea], total: total}
      assert basket.total == PricingRule.reduce(basket).total
    end

    test "basket with one green tea and with pricing rules for green tea do not reduce price", %{
      green_tea: green_tea
    } do
      pricing_rules = %{"GR1" => [Cashier.Core.PricingRule.BOGO]}

      basket = %Basket{
        products: [green_tea],
        pricing_rules: pricing_rules,
        total: green_tea.price
      }

      assert basket.total == PricingRule.reduce(basket).total
    end

    test "basket with two green tea's and with with pricing rules for green tea reduce's price",
         %{
           green_tea: green_tea
         } do
      total = Money.multiply(green_tea.price, 2)
      pricing_rules = %{"GR1" => [Cashier.Core.PricingRule.BOGO]}

      basket = %Basket{
        products: [green_tea, green_tea],
        pricing_rules: pricing_rules,
        total: total
      }

      assert green_tea.price == PricingRule.reduce(basket).total
    end

    test "basket with three green tea's and with pricing rules for green tea reduce price", %{
      green_tea: green_tea
    } do
      result = Money.multiply(green_tea.price, 2)
      total = Money.multiply(green_tea.price, 3)
      pricing_rules = %{"GR1" => [Cashier.Core.PricingRule.BOGO]}

      basket = %Basket{
        products: [green_tea, green_tea, green_tea],
        pricing_rules: pricing_rules,
        total: total
      }

      assert result == PricingRule.reduce(basket).total
    end

    test "basket with one green tea and with pricing rules for coffee do not reduce price", %{
      green_tea: green_tea
    } do
      pricing_rules = %{"CF1" => [Cashier.Core.PricingRule.BOGO]}

      basket = %Basket{
        products: [green_tea],
        total: green_tea.price,
        pricing_rules: pricing_rules
      }

      assert basket.total == PricingRule.reduce(basket).total
    end

    test "basket with two green tea's and with pricing rules for coffee do not reduce price", %{
      green_tea: green_tea
    } do
      total = Money.multiply(green_tea.price, 2)
      pricing_rules = %{"CF1" => [Cashier.Core.PricingRule.BOGO]}

      basket = %Basket{
        products: [green_tea, green_tea],
        total: total,
        pricing_rules: pricing_rules
      }

      assert basket.total == PricingRule.reduce(basket).total
    end

    test "basket with three green tea's and with pricing rules for coffee do not reduce price", %{
      green_tea: green_tea
    } do
      total = Money.multiply(green_tea.price, 3)
      pricing_rules = %{"CF1" => [Cashier.Core.PricingRule.BOGO]}

      basket = %Basket{
        products: [green_tea, green_tea, green_tea],
        total: total,
        pricing_rules: pricing_rules
      }

      assert basket.total == PricingRule.reduce(basket).total
    end
  end
end

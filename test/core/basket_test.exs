defmodule Cashier.Core.BasketTest do
  use ExUnit.Case
  alias Cashier.Core.{Basket, Product}

  setup do
    green_tea = Product.find("GR1")
    {:ok, green_tea: green_tea}
  end

  describe "Basket.new/1" do
    test "new basket with pricing_rules returns basket with default values and passed pricing_rules" do
      pricing_rules = %{
        "GR1" => [Cashier.Core.PricingRule.BOGO],
        "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff],
        "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice]
      }

      basket = Basket.new(pricing_rules)
      refute %{} == basket
      assert Map.has_key?(basket, :uuid)
      assert Map.has_key?(basket, :pricing_rules)
      assert Map.has_key?(basket, :total)
      assert Map.has_key?(basket, :products)
      assert is_binary(basket.uuid)
      assert pricing_rules == basket.pricing_rules
      assert basket.total == Money.new(0, :GBP)
      assert [] == basket.products
    end

    test "new basket with empty pricing_rules returns basket with default values and passed pricing_rules" do
      pricing_rules = %{}

      basket = Basket.new(pricing_rules)
      refute %{} == basket
      assert Map.has_key?(basket, :uuid)
      assert Map.has_key?(basket, :pricing_rules)
      assert Map.has_key?(basket, :total)
      assert Map.has_key?(basket, :products)
      assert is_binary(basket.uuid)
      assert pricing_rules == basket.pricing_rules
      assert basket.total == Money.new(0, :GBP)
      assert [] == basket.products
    end
  end

  describe "Basket.scan/2" do
    test "scanning empty basket with green tea return basket with one green tea and total price updated",
         %{green_tea: green_tea} do
      pricing_rules = %{"GR1" => [Cashier.Core.PricingRule.BOGO]}
      basket = Basket.new(pricing_rules) |> Basket.scan(green_tea)
      assert green_tea.price == basket.total
      assert [green_tea] == basket.products
    end

    test "scanning green tea for basket with one green tea return basket with two green tea's and total price updated",
         %{green_tea: green_tea} do
      pricing_rules = %{"GR1" => [Cashier.Core.PricingRule.BOGO]}

      basket =
        %Basket{products: [green_tea], total: green_tea.price, pricing_rules: pricing_rules}
        |> Basket.scan(green_tea)

      total = Money.multiply(green_tea.price, 2)
      assert total == basket.total
      assert [green_tea, green_tea] == basket.products
    end
  end

  describe "Basket.total/1" do
    test "empty basket returns 0 pounds" do
      pricing_rules = %{"GR1" => [Cashier.Core.PricingRule.BOGO]}
      basket = %Basket{pricing_rules: pricing_rules}
      result = Money.new(0, :GBP) |> Money.to_string()
      assert result == Basket.total(basket)
    end

    test "basket with one green tea returns price of one green tea", %{green_tea: green_tea} do
      pricing_rules = %{"GR1" => [Cashier.Core.PricingRule.BOGO]}

      basket = %Basket{
        pricing_rules: pricing_rules,
        products: [green_tea],
        total: green_tea.price
      }

      result = Money.to_string(green_tea.price)
      assert result == Basket.total(basket)
    end

    test "basket with two green tea returns price of one green tea because pricing rules were applied",
         %{green_tea: green_tea} do
      total = Money.multiply(green_tea.price, 2)
      pricing_rules = %{"GR1" => [Cashier.Core.PricingRule.BOGO]}

      basket = %Basket{
        pricing_rules: pricing_rules,
        products: [green_tea, green_tea],
        total: total
      }

      result = Money.to_string(green_tea.price)
      assert result == Basket.total(basket)
    end
  end
end

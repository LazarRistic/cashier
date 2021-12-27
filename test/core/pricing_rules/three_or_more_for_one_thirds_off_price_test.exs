defmodule Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPriceTest do
  use ExUnit.Case, async: true
  alias Cashier.Core.{Basket, Product}
  alias Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice

  setup do
    coffee = Product.find("CF1")
    {:ok, coffee: coffee}
  end

  describe "ThreeOrMoreForOneThirdsOffPrice.applicable?/1" do
    test "basket with no products is not applicable for discount" do
      basket = %Basket{}
      refute ThreeOrMoreForOneThirdsOffPrice.applicable?(basket)
    end

    test "basket with one coffee is not applicable for discount", %{coffee: coffee} do
      basket = %Basket{products: [coffee]}
      refute ThreeOrMoreForOneThirdsOffPrice.applicable?(basket)
    end

    test "basket with two coffee is not applicable for discount", %{coffee: coffee} do
      basket = %Basket{products: [coffee, coffee]}
      refute ThreeOrMoreForOneThirdsOffPrice.applicable?(basket)
    end

    test "basket with three coffee is applicable for discount", %{coffee: coffee} do
      basket = %Basket{products: [coffee, coffee, coffee]}
      assert ThreeOrMoreForOneThirdsOffPrice.applicable?(basket)
    end

    test "basket with four coffee is applicable for discount", %{coffee: coffee} do
      basket = %Basket{products: [coffee, coffee, coffee, coffee]}
      assert ThreeOrMoreForOneThirdsOffPrice.applicable?(basket)
    end

    test "wrong type for basket is not applicable for discounts" do
      refute ThreeOrMoreForOneThirdsOffPrice.applicable?(nil)
    end
  end

  describe "ThreeOrMoreForOneThirdsOffPrice.apply/1" do
    test "basket with no products doesn't apply discounts" do
      basket = %Basket{}
      assert basket.total == ThreeOrMoreForOneThirdsOffPrice.apply(basket)
    end

    test "basket with one coffee doesn't apply discounts", %{coffee: coffee} do
      basket = %Basket{products: [coffee], total: coffee.price}
      assert coffee.price == ThreeOrMoreForOneThirdsOffPrice.apply(basket)
    end

    test "basket with two coffee doesn't apply discounts", %{coffee: coffee} do
      result = Money.multiply(coffee.price, 2)
      total = Money.multiply(coffee.price, 2)
      basket = %Basket{products: [coffee, coffee], total: total}

      assert result == ThreeOrMoreForOneThirdsOffPrice.apply(basket)
    end

    test "basket with three coffee applies a discount where all products are 2/3 of their value",
         %{coffee: coffee} do
      result = Money.multiply(coffee.price, 2)
      total = Money.multiply(coffee.price, 3)
      basket = %Basket{products: [coffee, coffee, coffee], total: total}

      assert result == ThreeOrMoreForOneThirdsOffPrice.apply(basket)
    end

    test "basket with four coffee applies a discount where all products are 2/3 of their value",
         %{
           coffee: coffee
         } do
      discounted_coffee =
        coffee.price
        |> Money.multiply(2)
        |> Money.divide(3)
        |> List.first()

      total =
        discounted_coffee
        |> Money.multiply(3)
        |> Money.add(coffee.price)

      result =
        discounted_coffee
        |> Money.multiply(4)

      basket = %Basket{products: [coffee, coffee, coffee, coffee], total: total}

      assert result == ThreeOrMoreForOneThirdsOffPrice.apply(basket)
    end

    test "wrong type for basket raises FunctionClauseError exception" do
      assert_raise FunctionClauseError, fn -> ThreeOrMoreForOneThirdsOffPrice.apply(nil) end
    end
  end
end

defmodule Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOffTest do
  use ExUnit.Case, async: true
  alias Cashier.Core.{Basket, Product}
  alias Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff

  setup do
    strawberries = Product.find("SR1")
    {:ok, strawberries: strawberries}
  end

  describe "ThreeOrMoreForFivePenceOff.applicable?/1" do
    test "basket with no products is not applicable for discount" do
      basket = %Basket{}
      refute ThreeOrMoreForFivePenceOff.applicable?(basket)
    end

    test "basket with one strawberry is not applicable for discount", %{
      strawberries: strawberries
    } do
      basket = %Basket{products: [strawberries]}
      refute ThreeOrMoreForFivePenceOff.applicable?(basket)
    end

    test "basket with two strawberries is not applicable for discount", %{
      strawberries: strawberries
    } do
      basket = %Basket{products: [strawberries, strawberries]}
      refute ThreeOrMoreForFivePenceOff.applicable?(basket)
    end

    test "basket with three strawberries is applicable for discount", %{
      strawberries: strawberries
    } do
      basket = %Basket{products: [strawberries, strawberries, strawberries]}
      assert ThreeOrMoreForFivePenceOff.applicable?(basket)
    end

    test "basket with four strawberries is applicable for discount", %{strawberries: strawberries} do
      basket = %Basket{products: [strawberries, strawberries, strawberries, strawberries]}
      assert ThreeOrMoreForFivePenceOff.applicable?(basket)
    end

    test "wrong type for basket is not applicable for discounts" do
      refute ThreeOrMoreForFivePenceOff.applicable?(nil)
    end
  end

  describe "ThreeOrMoreForFivePenceOff.apply/1" do
    test "basket with no products doesn't apply discounts" do
      basket = %Basket{}
      assert basket.total == ThreeOrMoreForFivePenceOff.apply(basket)
    end

    test "basket with one strawberry doesn't apply discounts", %{strawberries: strawberries} do
      basket = %Basket{products: [strawberries], total: strawberries.price}
      assert strawberries.price == ThreeOrMoreForFivePenceOff.apply(basket)
    end

    test "basket with two strawberries doesn't apply discounts", %{strawberries: strawberries} do
      result = Money.multiply(strawberries.price, 2)
      total = Money.multiply(strawberries.price, 2)
      basket = %Basket{products: [strawberries, strawberries], total: total}

      assert result == ThreeOrMoreForFivePenceOff.apply(basket)
    end

    test "basket with three strawberries applies a discount, total is price of two green tea's and third is 0.5 pounds less",
         %{strawberries: strawberries} do
      result = Money.new(4_50, :GBP) |> Money.multiply(3)
      total = Money.multiply(strawberries.price, 3)
      basket = %Basket{products: [strawberries, strawberries, strawberries], total: total}

      assert result == ThreeOrMoreForFivePenceOff.apply(basket)
    end

    test "basket with four strawberries applies a discount, total is price of two green tea's and third and fourth is 0.5 pounds less",
         %{strawberries: strawberries} do
      total =
        Money.new(4_50, :GBP)
        |> Money.add(Money.new(4_50, :GBP))
        |> Money.add(Money.new(4_50, :GBP))
        |> Money.add(strawberries.price)

      result = Money.new(4_50, :GBP) |> Money.multiply(4)

      basket = %Basket{
        products: [strawberries, strawberries, strawberries, strawberries],
        total: total
      }

      assert result == ThreeOrMoreForFivePenceOff.apply(basket)
    end

    test "wrong type for basket raises FunctionClauseError exception" do
      assert_raise FunctionClauseError, fn -> ThreeOrMoreForFivePenceOff.apply(nil) end
    end
  end
end

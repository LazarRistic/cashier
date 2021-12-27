defmodule Cashier.Core.PricingRule.BOGOTest do
  use ExUnit.Case, async: true
  alias Cashier.Core.{Basket, Product}
  alias Cashier.Core.PricingRule.BOGO

  setup do
    green_tea = Product.find("GR1")
    {:ok, green_tea: green_tea}
  end

  describe "BOGO.applicable?/1" do
    test "basket with no products and pricing rules is not applicable for discount" do
      basket = %Basket{products: []}
      refute BOGO.applicable?(basket)
    end

    test "basket with one green tea is not applicable for discount", %{green_tea: green_tea} do
      basket = %Basket{products: [green_tea]}
      refute BOGO.applicable?(basket)
    end

    test "basket with two green tea is applicable for discount", %{green_tea: green_tea} do
      basket = %Basket{products: [green_tea, green_tea]}
      assert BOGO.applicable?(basket)
    end

    test "basket with three green tea is applicable for discount", %{green_tea: green_tea} do
      basket = %Basket{products: [green_tea, green_tea, green_tea]}
      assert BOGO.applicable?(basket)
    end

    test "wrong type of basket raises FunctionClauseError exception" do
      assert_raise FunctionClauseError, fn -> BOGO.applicable?(nil) end
    end
  end

  describe "BOGO.apply/1" do
    test "basket with no products doesn't apply discounts" do
      basket = %Basket{}
      assert basket.total == BOGO.apply(basket)
    end

    test "basket with one green tea doesn't apply discounts", %{green_tea: green_tea} do
      basket = %Basket{products: [green_tea], total: green_tea.price}
      assert green_tea.price == BOGO.apply(basket)
    end

    test "basket with two green tea applies a discount, total is price of one green tea", %{
      green_tea: green_tea
    } do
      total = Money.multiply(green_tea.price, 2)
      basket = %Basket{products: [green_tea, green_tea], total: total}
      assert green_tea.price == BOGO.apply(basket)
    end

    test "basket with three green tea applies a discount, total is price of two green tea's", %{
      green_tea: green_tea
    } do
      result = Money.multiply(green_tea.price, 2)
      total = Money.multiply(green_tea.price, 2)
      basket = %Basket{products: [green_tea, green_tea, green_tea], total: total}
      assert result == BOGO.apply(basket)
    end

    test "wrong type for basket raises FunctionClauseError exception" do
      assert_raise FunctionClauseError, fn -> BOGO.apply(nil) end
    end
  end
end

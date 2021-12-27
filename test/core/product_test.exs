defmodule Cashier.Core.ProductTest do
  use ExUnit.Case, async: true
  alias Cashier.Core.Product

  setup do
    green_tea = %Product{
      code: "GR1",
      name: "Green tea",
      price: %Money{amount: 3_11, currency: :GBP}
    }

    strawberry = %Product{
      code: "SR1",
      name: "Strawberries",
      price: %Money{amount: 5_00, currency: :GBP}
    }

    coffee = %Product{
      code: "CF1",
      name: "Coffee",
      price: %Money{amount: 11_23, currency: :GBP}
    }

    {:ok, green_tea: green_tea, strawberry: strawberry, coffee: coffee}
  end

  describe "Product.parse/1" do
    test "parse map to product" do
      map = %{code: "code", name: "name", price: {0, :GBP}}
      result = %Product{code: "code", name: "name", price: %Money{amount: 0, currency: :GBP}}

      assert result == Product.parse(map)
    end
  end

  describe "Product.all/0" do
    test "there is only green tea, strawberry and coffee in allowed Products", %{
      green_tea: green_tea,
      strawberry: strawberry,
      coffee: coffee
    } do
      products = Product.all()

      unknown = %Product{
        code: "UNKNOWN",
        name: "unknown",
        price: %Money{amount: 0, currency: :GBP}
      }

      assert 3 == length(products)
      assert green_tea in products
      assert strawberry in products
      assert coffee in products
      refute unknown in products
    end
  end

  describe "Product.find/1" do
    test "for green tea code result is green tea", %{green_tea: green_tea} do
      assert ^green_tea = Product.find(green_tea.code)
    end

    test "for strawberry code result is strawberry", %{strawberry: strawberry} do
      assert ^strawberry = Product.find(strawberry.code)
    end

    test "for coffee code result is coffee", %{coffee: coffee} do
      assert ^coffee = Product.find(coffee.code)
    end
  end
end

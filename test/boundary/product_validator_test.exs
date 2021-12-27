defmodule Cashier.Boundary.ProductValidatorTest do
  use ExUnit.Case
  alias Cashier.Boundary.ProductValidator
  alias Cashier.Core.Product

  describe "ProductValidator.errors/1" do
    test "nil as product returns error tuple" do
      assert [{:error, _}] = ProductValidator.errors(nil)
    end

    test "empty list as product returns error tuple" do
      assert [{:error, _}] = ProductValidator.errors([])
    end

    test "empty map as product returns error tuple" do
      assert [{:error, _}] = ProductValidator.errors(%{})
    end

    test "map with product fields as product returns error tuple" do
      assert [{:error, _}] =
               ProductValidator.errors(%{
                 code: "GR1",
                 name: "Green tea",
                 price: %Money{amount: 0, currency: :GBP}
               })
    end

    test "Product with code field as nil returns error tuple" do
      assert [{:code, _}] =
               ProductValidator.errors(%Product{
                 code: nil,
                 name: "Green tea",
                 price: %Money{amount: 0, currency: :GBP}
               })
    end

    test "Product with name field as nil returns error tuple" do
      assert [{:name, _}] =
               ProductValidator.errors(%Product{
                 code: "GR1",
                 name: nil,
                 price: %Money{amount: 0, currency: :GBP}
               })
    end

    test "Product with missing code field returns error tuple" do
      assert [{:code, _}] =
               ProductValidator.errors(%Product{
                 name: "Green tea",
                 price: %Money{amount: 0, currency: :GBP}
               })
    end

    test "Product with missing name field returns error tuple" do
      assert [{:name, _}] =
               ProductValidator.errors(%Product{
                 code: "GR1",
                 price: %Money{amount: 0, currency: :GBP}
               })
    end

    test "Product with missing all field's returns error tuple" do
      assert [{:code, _}, {:name, _}, {:price, _}] = ProductValidator.errors(%Product{})
    end

    test "Product with missing price field returns error tuple" do
      assert [{:price, _}] = ProductValidator.errors(%Product{code: "GR1", name: "Green tea"})
    end

    test "Product with missing name field and price is not Money struct returns error tuple" do
      assert [{:name, _}, {:price, _}] =
               ProductValidator.errors(%Product{code: "GR1", price: %{amount: 0, currency: :GBP}})
    end

    test "Product with price field as nil returns error tuple" do
      assert [{:price, _}] =
               ProductValidator.errors(%Product{code: "GR1", name: "Green tea", price: nil})
    end

    test "Product with all field's as nil returns error tuple" do
      assert [{:code, _}, {:name, _}, {:price, _}] =
               ProductValidator.errors(%Product{code: nil, name: nil, price: nil})
    end

    test "Product with all field's valid, returns :ok" do
      assert :ok =
               ProductValidator.errors(%Product{
                 code: "GR1",
                 name: "Green tea",
                 price: %Money{amount: 3_11, currency: :GBP}
               })
    end
  end
end

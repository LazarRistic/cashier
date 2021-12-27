defmodule CashierTest do
  use ExUnit.Case
  alias Cashier.Core.Product

  setup do
    green_tea = "GR1"
    strawberry = "SR1"
    coffee = "CF1"

    pricing_rules = %{
      "GR1" => [Cashier.Core.PricingRule.BOGO],
      "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff],
      "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice]
    }

    {:ok,
     green_tea: green_tea, strawberry: strawberry, coffee: coffee, pricing_rules: pricing_rules}
  end

  describe "Whole transaction" do
    test "add green tea, strawberry, green tea, green tea, coffee in basket, total of the basket returns £22.45",
         %{
           green_tea: green_tea,
           strawberry: strawberry,
           coffee: coffee,
           pricing_rules: pricing_rules
         } do
      name = "Lazar Ristic"
      assert :ok == Cashier.new(name, pricing_rules)
      assert :ok == Cashier.scan(name, green_tea)
      assert :ok == Cashier.scan(name, strawberry)
      assert :ok == Cashier.scan(name, green_tea)
      assert :ok == Cashier.scan(name, green_tea)
      assert :ok == Cashier.scan(name, coffee)
      assert "£22.45" == Cashier.total(name)
    end

    test "add green tea, green tea in basket, total of the basket returns £3.11", %{
      green_tea: green_tea,
      pricing_rules: pricing_rules
    } do
      name = "Lazar Ristic"
      assert :ok == Cashier.new(name, pricing_rules)
      assert :ok == Cashier.scan(name, green_tea)
      assert :ok == Cashier.scan(name, green_tea)
      assert "£3.11" == Cashier.total(name)
    end

    test "add strawberry, strawberry, green tea, strawberry in basket, total of the basket returns £16.61",
         %{green_tea: green_tea, strawberry: strawberry, pricing_rules: pricing_rules} do
      name = "Lazar Ristic"
      assert :ok == Cashier.new(name, pricing_rules)
      assert :ok == Cashier.scan(name, strawberry)
      assert :ok == Cashier.scan(name, strawberry)
      assert :ok == Cashier.scan(name, green_tea)
      assert :ok == Cashier.scan(name, strawberry)
      assert "£16.61" == Cashier.total(name)
    end

    test "add green tea, coffee, strawberry, coffee, coffee in basket, total of the basket returns £30.57",
         %{
           green_tea: green_tea,
           strawberry: strawberry,
           coffee: coffee,
           pricing_rules: pricing_rules
         } do
      name = "Lazar Ristic"
      assert :ok == Cashier.new(name, pricing_rules)
      assert :ok == Cashier.scan(name, green_tea)
      assert :ok == Cashier.scan(name, coffee)
      assert :ok == Cashier.scan(name, strawberry)
      assert :ok == Cashier.scan(name, coffee)
      assert :ok == Cashier.scan(name, coffee)
      assert "£30.57" == Cashier.total(name)
    end
  end

  test "Test concurrent transactions with product code", %{
    green_tea: green_tea,
    strawberry: strawberry,
    coffee: coffee,
    pricing_rules: pricing_rules
  } do
    name1 = "Lazar Ristic"
    name2 = "Lazar Ristic 2"
    name3 = "Lazar Ristic 3"
    name4 = "Lazar Ristic 4"
    assert :ok == Cashier.new(name1, pricing_rules)
    assert :ok == Cashier.scan(name1, green_tea)
    assert :ok == Cashier.new(name2, pricing_rules)
    assert :ok == Cashier.scan(name1, strawberry)
    assert :ok == Cashier.new(name3, pricing_rules)
    assert :ok == Cashier.scan(name3, strawberry)
    assert :ok == Cashier.new(name4, pricing_rules)

    assert [{name1, pid1}] = Cashier.active_sessions_for(name1)
    assert [{name2, pid2}] = Cashier.active_sessions_for(name2)
    assert [{name3, pid3}] = Cashier.active_sessions_for(name3)
    assert [{name4, pid4}] = Cashier.active_sessions_for(name4)

    assert {:error, {:already_started, pid1}} == Cashier.new(name1, pricing_rules)
    assert {:error, {:already_started, pid2}} == Cashier.new(name2, pricing_rules)
    assert {:error, {:already_started, pid3}} == Cashier.new(name3, pricing_rules)
    assert {:error, {:already_started, pid4}} == Cashier.new(name4, pricing_rules)

    assert :ok == Cashier.scan(name1, green_tea)
    assert :ok == Cashier.scan(name1, green_tea)
    assert :ok == Cashier.scan(name1, coffee)
    assert "£22.45" == Cashier.total(name1)
    assert [] == Cashier.active_sessions_for(name1)

    assert :ok == Cashier.scan(name2, green_tea)
    assert :ok == Cashier.scan(name2, green_tea)
    assert "£3.11" == Cashier.total(name2)
    assert [] == Cashier.active_sessions_for(name2)

    assert :ok == Cashier.scan(name3, strawberry)
    assert :ok == Cashier.scan(name3, green_tea)
    assert :ok == Cashier.scan(name3, strawberry)
    assert "£16.61" == Cashier.total(name3)
    assert [] == Cashier.active_sessions_for(name3)

    assert :ok == Cashier.scan(name4, green_tea)
    assert :ok == Cashier.scan(name4, coffee)
    assert :ok == Cashier.scan(name4, strawberry)
    assert :ok == Cashier.scan(name4, coffee)
    assert :ok == Cashier.scan(name4, coffee)
    assert "£30.57" == Cashier.total(name4)
    assert [] == Cashier.active_sessions_for(name4)

    name5 = "Lazar Ristic 5"
    assert {:error, _} = Cashier.new(name5, nil)
    assert :ok == Cashier.new(name5, %{})
    assert {:error, _} = Cashier.scan(name5, nil)
    assert {:error, _} = Cashier.scan(name5, "UNKNOWN")
    assert "£0.00" == Cashier.total(name5)
    assert [] == Cashier.active_sessions_for(name5)
  end

  test "Test concurrent transactions with `Product` struct", %{
    green_tea: green_tea,
    strawberry: strawberry,
    coffee: coffee,
    pricing_rules: pricing_rules
  } do
    green_tea = Product.find(green_tea)
    strawberry = Product.find(strawberry)
    coffee = Product.find(coffee)

    name1 = "Lazar Ristic"
    name2 = "Lazar Ristic 2"
    name3 = "Lazar Ristic 3"
    name4 = "Lazar Ristic 4"
    assert :ok == Cashier.new(name1, pricing_rules)
    assert :ok == Cashier.scan(name1, green_tea)
    assert :ok == Cashier.new(name2, pricing_rules)
    assert :ok == Cashier.scan(name1, strawberry)
    assert :ok == Cashier.new(name3, pricing_rules)
    assert :ok == Cashier.scan(name3, strawberry)
    assert :ok == Cashier.new(name4, pricing_rules)

    assert [{name1, pid1}] = Cashier.active_sessions_for(name1)
    assert [{name2, pid2}] = Cashier.active_sessions_for(name2)
    assert [{name3, pid3}] = Cashier.active_sessions_for(name3)
    assert [{name4, pid4}] = Cashier.active_sessions_for(name4)

    assert {:error, {:already_started, pid1}} == Cashier.new(name1, pricing_rules)
    assert {:error, {:already_started, pid2}} == Cashier.new(name2, pricing_rules)
    assert {:error, {:already_started, pid3}} == Cashier.new(name3, pricing_rules)
    assert {:error, {:already_started, pid4}} == Cashier.new(name4, pricing_rules)

    assert :ok == Cashier.scan(name1, green_tea)
    assert :ok == Cashier.scan(name1, green_tea)
    assert :ok == Cashier.scan(name1, coffee)
    assert "£22.45" == Cashier.total(name1)
    assert [] == Cashier.active_sessions_for(name1)

    assert :ok == Cashier.scan(name2, green_tea)
    assert :ok == Cashier.scan(name2, green_tea)
    assert "£3.11" == Cashier.total(name2)
    assert [] == Cashier.active_sessions_for(name2)

    assert :ok == Cashier.scan(name3, strawberry)
    assert :ok == Cashier.scan(name3, green_tea)
    assert :ok == Cashier.scan(name3, strawberry)
    assert "£16.61" == Cashier.total(name3)
    assert [] == Cashier.active_sessions_for(name3)

    assert :ok == Cashier.scan(name4, green_tea)
    assert :ok == Cashier.scan(name4, coffee)
    assert :ok == Cashier.scan(name4, strawberry)
    assert :ok == Cashier.scan(name4, coffee)
    assert :ok == Cashier.scan(name4, coffee)
    assert "£30.57" == Cashier.total(name4)
    assert [] == Cashier.active_sessions_for(name4)

    name5 = "Lazar Ristic 5"
    assert {:error, _} = Cashier.new(name5, nil)
    assert :ok == Cashier.new(name5, %{})
    assert {:error, _} = Cashier.scan(name5, nil)

    assert {:error, _} =
             Cashier.scan(name5, %Product{code: "UKN", name: "UNKNOWN", price: Money.new(0, :GBP)})

    assert "£0.00" == Cashier.total(name5)
    assert [] == Cashier.active_sessions_for(name5)
  end
end

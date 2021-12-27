defmodule CashierTest do
  use ExUnit.Case
  doctest Cashier

  test "add green tea, strawberry, green tea, green tea, coffee in basket, total of the basket returns £22.45" do
    assert "£22.45" = false
  end

  test "add green tea, green tea in basket, total of the basket returns £3.11" do
    assert "£3.11" = false
  end

  test "add strawberry, strawberry, green tea, strawberry in basket, total of the basket returns £16.61" do
    assert "£16.61" = false
  end

  test "add green tea, coffee, strawberry, coffee, coffee in basket, total of the basket returns £30.57" do
    assert "£30.57" == false
  end
end

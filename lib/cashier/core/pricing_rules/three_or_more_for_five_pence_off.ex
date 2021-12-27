defmodule Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff do
  @moduledoc """
    Uses `PricingRule` to add if you buy 3 or more of same `Products` with this `Pricing Rule`, the price should drop by £0.50
    per product after minimum number of products.
  """
  use Cashier.Core.PricingRule
  alias Cashier.Core.Basket

  @min_number_of_products 3
  @discounted_price 5_0

  @impl true
  @doc """
    Overrides default implementation to return that pricing rule is applicable if there is more then min number of products in `Basket`

    `Basket` should be filtered with `Product` code that contains ThreeOrMoreForFivePenceOff `Pricing Rule`
  """
  def applicable?(%Basket{products: products}) when length(products) >= @min_number_of_products,
    do: true

  @impl true
  def applicable?(_), do: false

  @impl true
  @doc """
    Overrides default implementation to return discounted price

    `Basket` should be filtered with `Product` code that contains ThreeOrMoreForFivePenceOff `Pricing Rule`
  """
  def apply(%Basket{products: products, total: total})
      when length(products) == @min_number_of_products,
      do: Money.subtract(total, @min_number_of_products * @discounted_price)

  @impl true
  def apply(%Basket{products: products, total: total})
      when length(products) > @min_number_of_products,
      do: Money.subtract(total, @discounted_price)

  @impl true
  def apply(%Basket{total: total}), do: total
end

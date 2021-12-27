defmodule Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice do
  @moduledoc """
    Uses `PricingRule` to add if you buy 3 or more `Products`, the price of same `Products` with this `Pricing Rule` should drop
    to two thirds of the original price.
  """
  use Cashier.Core.PricingRule
  alias Cashier.Core.{Basket, Product}

  @min_number_of_products 3
  @discounted_price 1 / 3

  @impl true
  @doc """
    Overrides default implementation to return that pricing rule is applicable if there is more then min number of products in `Basket`

    `Basket` should be filtered with `Product` code that contains ThreeOrMoreForOneThirdsOffPrice `Pricing Rule`
  """
  def applicable?(%Basket{products: products}) when length(products) >= @min_number_of_products,
    do: true

  @impl true
  def applicable?(_), do: false

  @impl true
  @doc """
    Overrides default implementation to return discounted price

    `Basket` should be filtered with `Product` code that contains ThreeOrMoreForOneThirdsOffPrice `Pricing Rule`
  """
  def apply(%Basket{products: [%Product{price: price} | _] = products, total: total})
      when length(products) == @min_number_of_products,
      do: Money.subtract(total, price)

  @impl true
  def apply(%Basket{products: [product | _] = products, total: total})
      when length(products) > @min_number_of_products,
      do: Money.subtract(total, Money.multiply(product.price, @discounted_price))

  @impl true
  def apply(%Basket{total: total}), do: total
end

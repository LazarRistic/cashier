defmodule Cashier.Core.PricingRule.BOGO do
  @moduledoc """
    Uses `PricingRule` to add buy one get one free price rule
  """
  use Cashier.Core.PricingRule
  alias Cashier.Core.Basket
  require Integer

  @impl true
  @doc """
    Overrides default implementation to return that pricing rule is applicable if there is more then two products in `Basket`

    `Basket` should be filtered with `Product` code that contains Buy One Get One Free `Pricing Rule`
  """
  def applicable?(%Basket{products: products}), do: length(products) >= 2

  @impl true
  @doc """
    Overrides default implementation to return discounted price

    `Basket` should be filtered with `Product` code that contains Buy One Get One Free `Pricing Rule`
  """
  def apply(%Basket{products: [product | _] = products, total: total})
      when Integer.is_even(length(products)),
      do: Money.subtract(total, product.price)

  @impl true
  def apply(%Basket{total: total}), do: total
end

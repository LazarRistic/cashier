defmodule Cashier do
  alias Cashier.Core.{Basket, Product}

  @moduledoc """
    Documentation for `Cashier`.
  """

  @type uuid :: <<_::288>>

  @spec new(map()) :: Basket.t() | {atom(), String.t()}
  @doc ~S"""
    Create a new `Basket` struct from map of pricing rules.

    ## Examples

        iex> pricing_rules = %{
        ...>   "GR1" => [Cashier.Core.PricingRule.BOGO],
        ...>   "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff],
        ...>   "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice],
        ...> }
        %{
          "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice],
          "GR1" => [Cashier.Core.PricingRule.BOGO],
          "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff]
        }
        iex> Cashier.new(pricing_rules)
        %Cashier.Core.Basket{
          pricing_rules: %{
            "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice],
            "GR1" => [Cashier.Core.PricingRule.BOGO],
            "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff]
          },
          products: [],
          total: %Money{amount: 0, currency: :GBP}
        }
  """
  def new(pricing_rules) when is_map(pricing_rules), do: Basket.new(pricing_rules)
  def new(_), do: {:error, "Pricing Rules must be a map"}

  @spec scan(Basket.t(), Product.t()) :: Basket.t() | {atom(), String.t()}
  @doc ~S"""
    Adds `Product` to 'Basket' and updates total price of `Basket` not counting pricing rules

    ## Examples
        iex> Cashier.scan(%Cashier.Core.Basket{
        ...>  pricing_rules: %{
        ...>    "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice],
        ...>    "GR1" => [Cashier.Core.PricingRule.BOGO],
        ...>    "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff]
        ...>  },
        ...>  products: [],
        ...>  total: %Money{amount: 0, currency: :GBP},
        ...>  uuid: "72eb3e38-5019-486d-b57e-d6f7fd160dfa"
        ...>  },
        ...> %Cashier.Core.Product{code: "GR1", name: "Green tea", price: %Money{amount: 311, currency: :GBP}})
        %Cashier.Core.Basket{
          pricing_rules: %{
            "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice],
            "GR1" => [Cashier.Core.PricingRule.BOGO],
            "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff]
          },
          products: [
            %Cashier.Core.Product{
              code: "GR1",
              name: "Green tea",
              price: %Money{amount: 311, currency: :GBP}
            }
          ],
          total: %Money{amount: 311, currency: :GBP},
          uuid: "72eb3e38-5019-486d-b57e-d6f7fd160dfa"
        }
  """
  def scan(%Basket{} = basket, %Product{} = product), do: Basket.scan(basket, product)
  def scan(%Basket{}, _product), do: {:error, "product must be a `Product` struct"}
  def scan(_basket, %Product{}), do: {:error, "basket must be a `Basket` struct"}

  def scan(_basket, _product),
    do: {:error, "basket must be a `Basket` struct, product must be a `Product` struct"}

  @spec total(Basket.t()) :: String.t()
  @doc ~S"""
    Applies discounts and prints total price of 'Basket'

    ## Examples
        iex> Cashier.total %Cashier.Core.Basket{
        ...>  pricing_rules: %{
        ...>    "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice],
        ...>    "GR1" => [Cashier.Core.PricingRule.BOGO],
        ...>    "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff]
        ...>  },
        ...>  products: [
        ...>    %Cashier.Core.Product{
        ...>      code: "GR1",
        ...>      name: "Green tea",
        ...>      price: %Money{amount: 311, currency: :GBP}
        ...>    }
        ...>  ],
        ...>  total: %Money{amount: 311, currency: :GBP},
        ...>  uuid: "72eb3e38-5019-486d-b57e-d6f7fd160dfa"
        ...>}
        "£3.11"
  """
  def total(%Basket{} = basket) do
    Basket.total(basket)
  end
end

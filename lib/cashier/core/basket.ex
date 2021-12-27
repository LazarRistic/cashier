defmodule Cashier.Core.Basket do
  @moduledoc """
    Defines a 'Basket' struct along with convenience methods for working with basket, product and pricing rules

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
        iex> basket = Cashier.Core.Basket.new(pricing_rules)
        %Cashier.Core.Basket{
          pricing_rules: %{
            "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice],
            "GR1" => [Cashier.Core.PricingRule.BOGO],
            "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff]
          },
          products: [],
          total: %Money{amount: 0, currency: :GBP},
          uuid: "72eb3e38-5019-486d-b57e-d6f7fd160dfa"
        }
        iex> basket =
        ...> Cashier.Core.Basket.scan(basket, %Cashier.Core.Product{code: "GR1", name: "Green tea", price: %Money{amount: 311, currency: :GBP}})
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
        iex> Basket.total basket
        "£3.11"
  """
  alias Cashier.Core.{Product, PricingRule}

  defstruct uuid: UUID.uuid4(),
            products: [],
            total: Money.new(0, :GBP),
            pricing_rules: %{}

  @type t() :: %__MODULE__{
          uuid: Cashier.uuid(),
          products: [Product.t()],
          total: Money.t(),
          pricing_rules: map()
        }

  @spec new(map()) :: __MODULE__.t()
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
        iex> Cashier.Core.Basket.new(pricing_rules)
        %Cashier.Core.Basket{
          pricing_rules: %{
            "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice],
            "GR1" => [Cashier.Core.PricingRule.BOGO],
            "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff]
          },
          products: [],
          total: %Money{amount: 0, currency: :GBP},
          uuid: "72eb3e38-5019-486d-b57e-d6f7fd160dfa"
        }
  """
  def new(pricing_rules) do
    %__MODULE__{pricing_rules: pricing_rules}
  end

  @spec scan(__MODULE__.t(), Product.t()) :: __MODULE__.t()
  @doc ~S"""
    Adds `Product` to 'Basket' and updates total price of `Basket` not counting pricing rules

    ## Examples

        iex> Cashier.Core.Basket.scan(basket, %Cashier.Core.Product{code: "GR1", name: "Green tea", price: %Money{amount: 311, currency: :GBP}})
        %Cashier.Core.Basket{
          pricing_rules: %{
            "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice],
            "GR1" => [Cashier.Core.PricingRule.BOGO],
            "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff]
          },
          products: [
            ...
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
  def scan(
        %__MODULE__{products: products, total: total} = basket,
        %Product{price: price} = product
      ) do
    %{basket | products: [product | products], total: Money.add(total, price)}
  end

  @spec total(__MODULE__.t()) :: String.t()
  @doc ~S"""
    Applies pricing rules and prints total price of 'Basket'

    ## Examples

        iex> Basket.total basket
        "£3.11"
  """
  def total(%__MODULE__{} = basket) do
    basket
    |> _apply_pricing_rules()
    |> _print_total()
  end

  @spec _apply_pricing_rules(__MODULE__.t()) :: __MODULE__.t()
  defp _apply_pricing_rules(%__MODULE__{} = basket), do: PricingRule.reduce(basket)

  @spec _print_total(__MODULE__.t()) :: String.t()
  defp _print_total(%__MODULE__{total: total}), do: Money.to_string(total)
end

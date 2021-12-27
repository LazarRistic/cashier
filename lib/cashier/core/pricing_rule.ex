defmodule Cashier.Core.PricingRule do
  @moduledoc """
    Provides generic representation of pricing rules.

    ## Implementation

        use Cashier.Core.PricingRule

    ## Example

        iex> PricingRule.reduce(basket)
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
            },
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
  alias Cashier.Core.{Product, Basket}

  @type t :: module()

  @doc """
    Checks if the pricing rule is applicable to the product
  """
  @callback applicable?(Basket.t()) :: true | false

  @doc """
    Applies pricing rule to products in basket, returning discount
  """
  @callback apply(Basket.t()) :: Money.t()

  @spec reduce(Basket.t()) :: Basket.t()
  @doc ~S"""
    Trying to apply all pricing rules to all products in basket and change total

    ## Example

        iex> PricingRule.reduce(basket)
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
            },
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
  def reduce(%Basket{uuid: uuid, products: products, pricing_rules: pricing_rules, total: total}) do
    products
    |> Enum.reduce(%Basket{uuid: uuid, pricing_rules: pricing_rules, total: total}, fn
      %Product{code: code} = product,
      %Basket{products: products, pricing_rules: pricing_rules} = basket ->
        pricing_rules[code]
        |> case do
          nil ->
            basket

          rules ->
            rules
            |> Enum.reduce(%Basket{basket | products: [product | products]}, fn
              pricing_rules, %Basket{} = acc ->
                _maybe_apply_pricing_rules(acc, pricing_rules, code)
            end)
        end
    end)
  end

  @spec _maybe_apply_pricing_rules(Basket.t(), Cashier.Core.PricingRule.t(), String.t()) ::
          Basket.t()
  defp _maybe_apply_pricing_rules(%Basket{products: products} = basket, pricing_rules, code) do
    filtered_basket = Map.put(basket, :products, Enum.filter(products, &(&1.code == code)))

    filtered_basket
    |> pricing_rules.applicable?()
    |> if do
      new_price = pricing_rules.apply(filtered_basket)
      Map.put(basket, :total, new_price)
    else
      basket
    end
  end

  defmacro __using__(_opts) do
    quote do
      @moduledoc """
        Implementation of Cashier.Core.PricingRule behaviour
      """
      @behaviour Cashier.Core.PricingRule

      @impl true
      @spec applicable?(Basket.t()) :: true | false
      @doc ~S"""
        Default implementation
      """
      def applicable?(%Basket{pricing_rules: pricing_rules}),
        do: __MODULE__ in Enum.reduce(pricing_rules, [], fn {k, v}, acc -> [v | acc] end)

      @impl true
      @spec apply(Basket.t()) :: Money.t()
      @doc ~S"""
        Default implementation
      """
      def apply(%Basket{total: total}), do: total

      defoverridable applicable?: 1, apply: 1
    end
  end
end

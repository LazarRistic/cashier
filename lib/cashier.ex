defmodule Cashier do
  @moduledoc """
    Documentation for `Cashier`.
  """
  alias Cashier.Boundary.{Checkout, BasketValidator, ProductValidator}
  alias Cashier.Core.{Product, Basket}
  use DynamicSupervisor

  @type uuid :: <<_::288>>

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: init_arg)
  end

  @spec new(String.t(), map()) :: :ok | {atom(), String.t()}
  @doc ~S"""
    Create a new `Basket` struct from map of pricing rules and store it into state.

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
        iex> name = "Lazar Ristic"
        "Lazar Ristic"
        iex> Cashier.new(name, pricing_rules)
        :ok
  """
  def new(name, pricing_rules) when is_map(pricing_rules) do
    with {:ok, _pid} <-
           DynamicSupervisor.start_child(__MODULE__, {Checkout, [name: Checkout.via(name)]}),
         %Basket{} = basket <- Basket.new(pricing_rules),
         :ok <- BasketValidator.errors(basket) do
      Checkout.new(name, pricing_rules)
    end
  end

  def new(_, _), do: {:error, "Pricing Rules must be a map"}

  @spec scan(String.t(), Product.t() | String.t()) :: :ok | {atom(), String.t()}
  @doc ~S"""
    Adds `Product` to 'Basket' and updates total price of `Basket` not counting pricing rules and updates state

    ## Examples

        iex> Cashier.scan("Lazar Ristic", Cashier.Core.Product.find("GR1"))
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
  def scan(name, %Product{} = product) do
    with :ok <- ProductValidator.errors(product) do
      Checkout.scan(name, product)
    else
      error -> error
    end
  end

  def scan(name, product_code) when is_binary(product_code) do
    scan(name, Product.find(product_code))
  end

  def scan(_name, _product), do: {:error, "product must be struct of `Product` or product code"}

  @spec total(String.t()) :: String.t()
  @doc ~S"""
    Applies discounts, prints total price of 'Basket' and terminate's session

    ## Examples

        iex> Cashier.total "Lazar Ristic"
        "£3.11"
  """
  def total(name), do: Checkout.total(name)

  @spec active_sessions_for(String.t()) :: list
  @doc """
    Return's active session's filtered by name

    ## Example

        iex> Cashier.new "Lazar Ristic"
        :ok
        iex> Cashier.active_sessions_for("Lazar Ristic)
        [{"Laki", \#PID<0.217.0>}]
  """
  def active_sessions_for(name), do: Checkout.active_sessions_for(name)
end

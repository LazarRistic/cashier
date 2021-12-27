defmodule Cashier.Core.Product do
  @moduledoc """
    Defines a 'Product' struct along with convenience methods for getting Product structs

    ## Examples

        iex> Cashier.Core.Product.parse(%{code: "GR1", name: "Green tea", price: {3_11, :GBP}})
        %Cashier.Core.Product{
          code: "GR1",
          name: "Green tea",
          price: %Money{amount: 311, currency: :GBP}
        }
        iex> Cashier.Core.Product.all()
        [
          %Cashier.Core.Product{
            code: "GR1",
            name: "Green tea",
            price: %Money{amount: 311, currency: :GBP}
          },
          %Cashier.Core.Product{
            code: "SR1",
            name: "Strawberries",
            price: %Money{amount: 500, currency: :GBP}
          },
          %Cashier.Core.Product{
            code: "CF1",
            name: "Coffee",
            price: %Money{amount: 1123, currency: :GBP}
          }
        ]
        iex> Cashier.Core.Product.find("GR1")
        %Cashier.Core.Product{
          code: "GR1",
          name: "Green tea",
          price: %Money{amount: 311, currency: :GBP}
        }

    ## Configuration

    You can set products in Mix configuration

        config :cashier,
          :products, [                                                                        #Add all products your cashier app is recognizing
                      %{code: "GR1", name: "Green tea", price: {3_11, :GBP}},
                      %{code: "SR1", name: "Strawberries", price: {5_00, :GBP}},
                      %{code: "CF1", name: "Coffee", price: {11_23, :GBP}}
                     ]
  """
  defstruct ~w(code name price)a

  @type t() :: %__MODULE__{code: String.t(), name: String.t(), price: Money.t()}

  @spec parse(map()) :: __MODULE__.t()
  @doc ~S"""
    Create a new 'Product' struct from map

    ## Examples

        iex> Cashier.Core.Product.parse(%{code: "GR1", name: "Green tea", price: {3_11, :GBP}})
        %Cashier.Core.Product{code: "GR1", name: "Green tea", price: %Money{amount: 311, currency: :GBP}}
  """
  def parse(%{code: code, name: name, price: {amount, currency}}) do
    %__MODULE__{code: code, name: name, price: Money.new(amount, currency)}
  end

  @spec all() :: [__MODULE__.t()]
  @doc ~S"""
    List all 'Product' struct's added in Mix configuration

    ## Examples

        iex> Cashier.Core.Product.all()
        [
          %Cashier.Core.Product{code: "GR1", name: "Green tea", price: %Money{amount: 311, currency: :GBP}},
          %Cashier.Core.Product{code: "SR1", name: "Strawberries", price: %Money{amount: 500, currency: :GBP}},
          %Cashier.Core.Product{code: "CF1", name: "Coffee", price: %Money{amount: 1123, currency: :GBP}}
        ]
  """
  def all() do
    Application.get_env(:cashier, :products)
    |> Enum.reduce([], fn product, acc ->
      [parse(product) | acc]
    end)
    |> Enum.reverse()
  end

  @spec find(String.t()) :: __MODULE__.t() | nil
  @doc ~S"""
    Create a new 'Product' struct from code and searching all products in Mix configuration

    ## Examples

        iex> Cashier.Core.Product.find("GR1")
        %Cashier.Core.Product{code: "GR1", name: "Green tea", price: %Money{amount: 311, currency: :GBP}}
  """
  def find(code), do: Enum.find(all(), &(&1.code == code))
end

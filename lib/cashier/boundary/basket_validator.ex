defmodule Cashier.Boundary.BasketValidator do
  alias Cashier.Core.{Product, Basket}
  import Cashier.Boundary.Validator

  @app_key :cashier

  @spec errors(Basket.t()) :: :ok | list
  @doc """
    Validates basket and it's fields
    returns :ok if it's valid and {:error, message} if it's invalid
    also can return list of errors [field: message]

    ## Example

        iex> pricing_rules = %{
        ...>   "GR1" => [Cashier.Core.PricingRule.BOGO],
        ...>   "SR1" => [Cashier.Core.PricingRule.ThreeOrMoreForFivePenceOff],
        ...>   "CF1" => [Cashier.Core.PricingRule.ThreeOrMoreForOneThirdsOffPrice]
        ...> }
        iex> BasketValidator.errors(%Basket{pricing_rules: pricing_rules})
        :ok
        iex> pricing_rules = %{
        ...>   "GR1" => [Cashier.Core.PricingRule.UNKNOWN],
        ...>   "SR1" => [Cashier.Core.PricingRule.UNKNOWN],
        ...>   "CF1" => [Cashier.Core.PricingRule.UNKNOWN]
        ...> }
        iex> BasketValidator.errors(%Basket{pricing_rules: pricing_rules})
        [pricing_rules: "[Cashier.Core.PricingRule.UNKNOWN, Cashier.Core.PricingRule.UNKNOWN, Cashier.Core.PricingRule.UNKNOWN] are not defined pricing rules"]
  """
  def errors(%Basket{} = fields) when is_struct(fields) do
    []
    |> require(fields, :products, &_validate_products/1)
    |> require(fields, :total, &_validate_total/1)
    |> require(fields, :pricing_rules, &_validate_pricing_rules/1)
  end

  def errors(_fields), do: [{:error, "An Basket struct is required"}]

  @doc false
  defp _validate_products(products) when is_list(products) do
    products
    |> Enum.map(fn
      %Product{} = _product -> true
      _invalid -> false
    end)
    |> then(fn list ->
      if false in list do
        {:error, "product must be type of Product struct"}
      else
        :ok
      end
    end)
  end

  defp _validate_products(_products), do: {:error, "must be a list"}

  @doc false
  defp _validate_total(%Money{} = _total), do: :ok
  defp _validate_total(_total), do: {:error, "total must be type of Money struct"}

  @doc false
  defp _validate_pricing_rules(pricing_rules) when is_map(pricing_rules) do
    known_rules = Enum.flat_map(pricing_rules, &elem(&1, 1))

    unknown_rules =
      with {:ok, modules} <- :application.get_key(@app_key, :modules),
           do: known_rules -- modules

    case unknown_rules do
      [] -> :ok
      unknowns -> {:error, "#{inspect(unknowns)} are not defined pricing rules"}
    end
  end

  defp _validate_pricing_rules(_pricing_rules), do: {:error, "pricing rules must be a map"}
end

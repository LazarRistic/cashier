defmodule Cashier.Boundary.ProductValidator do
  import Cashier.Boundary.Validator
  alias Cashier.Core.Product

  @spec errors(Product.t()) :: :ok | list
  @doc """
    Validates product and it's fields
    returns :ok if it's valid and {:error, message} if it's invalid
    also can return list of errors [field: message]

    ## Example

        iex> ProductValidator.errors(%Product{
        ...>         code: "GR1",
        ...>         name: "Green tea",
        ...>         price: %Money{amount: 3_11, currency: :GBP}
        ...>       })
        :ok
        iex> ProductValidator.errors(%Product{})
        [
          code: "can't be blank",
          name: "can't be blank",
          price: "money must be Money struct"
        ]
  """
  def errors(%Product{} = fields) when is_struct(fields) do
    []
    |> require(fields, :code, &_validate_code/1)
    |> require(fields, :name, &_validate_name/1)
    |> require(fields, :price, &_validate_price/1)
    |> _is_product_valid?(fields)
  end

  def errors(_fields), do: [{:error, "An Product struct is required"}]

  @doc false
  defp _validate_code(code) when is_binary(code) do
    check(String.match?(code, ~r{\S}), {:error, "can't be blank"})
  end

  defp _validate_code(nil), do: {:error, "can't be blank"}
  defp _validate_code(_code), do: {:error, "must be a string"}

  @doc false
  defp _validate_name(name) when is_binary(name) do
    check(String.match?(name, ~r{\S}), {:error, "can't be blank"})
  end

  defp _validate_name(nil), do: {:error, "can't be blank"}
  defp _validate_name(_name), do: {:error, "must be a string"}

  @doc false
  defp _validate_price(%Money{amount: _amount, currency: _currency}), do: :ok
  defp _validate_price(_money), do: {:error, "money must be Money struct"}

  @doc false
  defp _is_product_valid?(:ok, %Product{} = product) do
    case product in Product.all() do
      true -> :ok
      false -> {:error, "Unknown product"}
    end
  end

  defp _is_product_valid?(errors, _product), do: errors
end

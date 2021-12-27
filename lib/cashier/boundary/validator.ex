defmodule Cashier.Boundary.Validator do
  @spec require(list(), struct(), atom(), (any -> :ok | {atom(), String.t()})) :: :ok | list
  @doc """
    Check if field is valid and existing
    returns :ok if it's valid and existing, and {error, message} if it's not
    also can return list of errors for [field: message]
  """
  def require(errors, fields, field_name, validator) do
    present = Map.has_key?(fields, field_name)
    _check_required_field(present, fields, errors, field_name, validator)
  end

  @spec check(boolean(), {:error, String.t()}) :: :ok | {:error, String.t()}
  @doc """
    If field is valid return :ok, else returns message
  """
  def check(true = _valid, _message), do: :ok
  def check(false = _valid, message), do: message

  @doc false
  defp _check_required_field(true = _present, fields, errors, field_name, f) do
    valid = fields |> Map.fetch!(field_name) |> f.()
    _check_field(valid, errors, field_name)
  end

  @doc false
  defp _check_required_field(_present, _fields, errors, field_name, _f) do
    errors ++ [{field_name, "is required"}]
  end

  @doc false
  defp _check_field(:ok, errors, _field_name) when is_list(errors) and length(errors) > 0,
    do: errors

  @doc false
  defp _check_field(:ok, _errors, _field_name), do: :ok

  @doc false
  defp _check_field({:error, message}, :ok, field_name) do
    [{field_name, message}]
  end

  @doc false
  defp _check_field({:error, message}, errors, field_name) do
    errors ++ [{field_name, message}]
  end

  @doc false
  defp _check_field({:errors, messages}, errors, field_name) do
    errors ++ Enum.map(messages, &{field_name, &1})
  end
end

defmodule Cashier.Boundary.ValidatorTest do
  use ExUnit.Case
  alias Cashier.Boundary.Validator
  alias Cashier.Core.Product

  describe "Validator.require/4" do
    test "valid product returns :ok" do
      errors = []

      fields = %Product{
        code: "GR1",
        name: "Green tea",
        price: %Money{amount: 311, currency: :GBP}
      }

      assert :ok =
               Validator.require(
                 errors,
                 fields,
                 :code,
                 &case &1 do
                   code when is_binary(code) ->
                     Validator.check(String.match?(code, ~r{\S}), {:error, "can't be blank"})

                   nil ->
                     {:error, "can't be blank"}

                   _code ->
                     {:error, "must be a string"}
                 end
               )

      assert :ok =
               Validator.require(
                 errors,
                 fields,
                 :name,
                 &case &1 do
                   code when is_binary(code) ->
                     Validator.check(String.match?(code, ~r{\S}), {:error, "can't be blank"})

                   nil ->
                     {:error, "can't be blank"}

                   _code ->
                     {:error, "must be a string"}
                 end
               )

      assert :ok =
               Validator.require(
                 errors,
                 fields,
                 :price,
                 &if &1 == %Money{amount: 311, currency: :GBP} do
                   :ok
                 else
                   {:error, "money must be Money struct"}
                 end
               )
    end

    test "in valid code in product returns error tuple" do
      errors = []

      fields = %Product{
        code: nil,
        name: "Green tea",
        price: %Money{amount: 311, currency: :GBP}
      }

      assert [{:code, "can't be blank"}] =
               Validator.require(
                 errors,
                 fields,
                 :code,
                 &case &1 do
                   code when is_binary(code) ->
                     Validator.check(String.match?(code, ~r{\S}), {:error, "can't be blank"})

                   nil ->
                     {:error, "can't be blank"}

                   _code ->
                     {:error, "must be a string"}
                 end
               )

      assert :ok =
               Validator.require(
                 errors,
                 fields,
                 :name,
                 &case &1 do
                   code when is_binary(code) ->
                     Validator.check(String.match?(code, ~r{\S}), {:error, "can't be blank"})

                   nil ->
                     {:error, "can't be blank"}

                   _code ->
                     {:error, "must be a string"}
                 end
               )

      assert :ok =
               Validator.require(
                 errors,
                 fields,
                 :price,
                 &if &1 == %Money{amount: 311, currency: :GBP} do
                   :ok
                 else
                   {:error, "money must be Money struct"}
                 end
               )
    end

    test "in valid name in product returns error tuple" do
      errors = []

      fields = %Product{
        code: "GR1",
        name: :invalid,
        price: %Money{amount: 311, currency: :GBP}
      }

      assert :ok =
               Validator.require(
                 errors,
                 fields,
                 :code,
                 &case &1 do
                   code when is_binary(code) ->
                     Validator.check(String.match?(code, ~r{\S}), {:error, "can't be blank"})

                   nil ->
                     {:error, "can't be blank"}

                   _code ->
                     {:error, "must be a string"}
                 end
               )

      assert [{:name, "must be a string"}] =
               Validator.require(
                 errors,
                 fields,
                 :name,
                 &case &1 do
                   code when is_binary(code) ->
                     Validator.check(String.match?(code, ~r{\S}), {:error, "can't be blank"})

                   nil ->
                     {:error, "can't be blank"}

                   _code ->
                     {:error, "must be a string"}
                 end
               )

      assert :ok =
               Validator.require(
                 errors,
                 fields,
                 :price,
                 &if &1 == %Money{amount: 311, currency: :GBP} do
                   :ok
                 else
                   {:error, "money must be Money struct"}
                 end
               )
    end
  end

  describe "Validator.check/2" do
    test "valid returns :ok" do
      assert :ok = Validator.check(true, {:error, "is not true"})
    end

    test "invalid returns error tuple" do
      assert {:error, _message} = Validator.check(false, {:error, "is not true"})
    end
  end
end

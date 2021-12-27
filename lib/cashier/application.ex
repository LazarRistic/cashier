defmodule Cashier.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  @doc false
  def start(_type, _args) do
    children = [
      {Registry, [name: Cashier.Registry.Checkout, keys: :unique]},
      {DynamicSupervisor, [name: Cashier, strategy: :one_for_one]}
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end

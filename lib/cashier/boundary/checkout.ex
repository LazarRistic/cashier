defmodule Cashier.Boundary.Checkout do
  alias Cashier.Core.{Basket, Product}
  use GenServer, restart: :transient

  @doc false
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, %Basket{}, init_arg)
  end

  @impl true
  @doc false
  def init(_init_arg) do
    {:ok, %Basket{}}
  end

  @impl true
  @doc false
  def handle_call({:new, pricing_rules}, _from, _state) do
    basket = Basket.new(pricing_rules)
    {:reply, :ok, basket}
  end

  @impl true
  @doc false
  def handle_call({:scan, %Product{} = product}, _from, state) do
    basket = Basket.scan(state, product)
    {:reply, :ok, basket}
  end

  @impl true
  @doc false
  def handle_call(:total, _from, state) do
    total = Basket.total(state)
    {:stop, :normal, total, nil}
  end

  @spec new(String.t(), map()) :: :ok
  @doc """
    Create's new instance for cashier with empty `Basket`
  """
  def new(params, pricing_rules) do
    GenServer.call(via(params), {:new, pricing_rules})
  end

  @spec scan(String.t(), Product.t()) :: :ok
  @doc """
    Adds `Product` to `Basket`
  """
  def scan(params, product) do
    GenServer.call(via(params), {:scan, product})
  end

  @spec total(String.t()) :: String.t()
  @doc """
    Prints total price of Basket and kills itself
  """
  def total(params) do
    GenServer.call(via(params), :total)
  end

  @spec via(String.t()) :: {:via, Registry, {Cashier.Registry.Checkout, String.t()}}
  @doc """
    Creating `via` tuple for registering process
  """
  def via(params) do
    {
      :via,
      Registry,
      {Cashier.Registry.Checkout, params}
    }
  end

  @spec active_sessions_for(String.t()) :: list
  @doc """
    Return's active session's filtered by name

    ## Example

        iex> Checkout.new "Lazar Ristic"
        :ok
        iex> Checkout.active_sessions_for("Lazar Ristic)
        [{"Laki", \#PID<0.217.0>}]
  """
  def active_sessions_for(name) do
    Cashier
    |> DynamicSupervisor.which_children()
    |> Enum.filter(&child_pid?/1)
    |> Enum.flat_map(&active_sessions_for(&1, name))
  end

  @doc false
  defp active_sessions_for({:undefined, pid, :worker, [__MODULE__]}, session_name) do
    Cashier.Registry.Checkout
    |> Registry.keys(pid)
    |> Enum.filter(fn name ->
      name == session_name
    end)
    |> Enum.map(fn name -> {name, pid} end)
  end

  @doc false
  defp child_pid?({:undefined, pid, :worker, [__MODULE__]}) when is_pid(pid), do: true
  defp child_pid?(_child), do: false
end

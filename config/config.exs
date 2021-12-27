import Config

config :money,
  default_currency: :GBP

config :cashier, :products, [
  %{code: "GR1", name: "Green tea", price: {3_11, :GBP}},
  %{code: "SR1", name: "Strawberries", price: {5_00, :GBP}},
  %{code: "CF1", name: "Coffee", price: {11_23, :GBP}}
]

import_config "#{Mix.env()}.exs"

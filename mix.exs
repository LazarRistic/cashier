defmodule Cashier.MixProject do
  use Mix.Project

  def project do
    [
      app: :cashier,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        dialyzer: :dev,
        bless: :test
      ],
      dialyzer: [
        plt_add_deps: :apps_direct,
        plt_add_apps: [:mix]
      ],
      name: "Cashier",
      docs: _docs(),
      deps: _deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Cashier.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp _deps do
    [
      {:elixir_uuid, "~> 1.2.0", optional: true},
      {:money, "~> 1.9"},
      {:jason, "~> 1.0"},
      {:decimal, "~> 2.0"},

      # test dependencies
      {:dialyxir, "~> 1.1.0", runtime: false},
      {:ex_doc, "~> 0.24", runtime: false},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end

  defp _docs do
    [
      output: "../doc/cashier"
    ]
  end
end

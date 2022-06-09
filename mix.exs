defmodule CreditCard.MixProject do
  use Mix.Project

  def project do
    [
      app: :credit_card,
      version: "0.3.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "This project aims to help with credit card validation and utilities",
      source_url: "https://github.com/alissonfpmorais/credit_card",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:luhn, "~> 0.3.0"}
    ]
  end

  defp package do
    [
      name: "credit_card_utils",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/alissonfpmorais/credit_card"}
    ]
  end
end

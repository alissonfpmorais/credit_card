defmodule PlasticCard.MixProject do
  use Mix.Project

  def project do
    [
      app: :plastic_card,
      version: "0.5.3",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "This project aims to help with plastic card validation and utilities",
      source_url: "https://github.com/alissonfpmorais/plastic_card",
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
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/alissonfpmorais/plastic_card"}
    ]
  end
end

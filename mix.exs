defmodule Predicator.Mixfile do
  use Mix.Project

  def project do
    [
      app: :predicator,
      version: "0.2.1",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: package(),
      description: description(),
      deps: deps()
    ]
  end

  def description(), do: "Predicator Evaluator in elixir"

  def package() do
    [
      name: :predicator,
      maintainers: ["Joshua Richardson"],
      licenses: ["MIT"],
      docs: [extras: ["README.md"]],
      links: %{"GitHub" => "https://github.com/predicator/predicator_elixir"}
    ]
  end

  def application() do
    [
      mod: {Predicator.Application, []},
      extra_applications: [
        :logger
      ]
    ]
  end

  defp deps() do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.16", only: :dev},
    ]
  end
end

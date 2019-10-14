defmodule Predicator.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :predicator,
      version: "0.7.2",
      elixir: "~> 1.6",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: package(),
      aliases: aliases(),
      description: description(),
      deps: deps()
    ]
  end

  def description(), do: "Predicate Evaluator"

  def package() do
    [
      name: :predicator,
      maintainers: ["Joshua Richardson", "johnnyt"],
      licenses: ["MIT"],
      docs: [extras: ["README.md"]],
      links: %{"GitHub" => "https://github.com/predicator/predicator_elixir"}
    ]
  end

  defp aliases() do
    [compile: "compile --warnings-as-errors"]
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
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19.0", only: :dev},
    ]
  end
end

# Predicator

_Currently has working Evaluator for Predicator instructions & limited lexing and parsing_

[predicator_elixir](https://hexdocs.pm/predicator) is a predicate evaluator for compiled rules from the [predicator](https://github.com/predicator/predicator) ruby gem

### Installation

The package can be installed by:

1. Adding to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:predicator, "~> 0.4.0"}]
  end
  ```

  or if you want to use the ecto types for predicator you can add the predicator_ecto lib.

  ```elixir
  def deps do
    [
      {:predicator, "~> 0.3"},
      {:predicator_ecto, "~> 0.1"},
    ]
  end
  ```

### Using



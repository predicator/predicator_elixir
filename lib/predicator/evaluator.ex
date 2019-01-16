defmodule Predicator.Evaluator do
  @moduledoc "Evaluator Module"
  alias Predicator.{
    Machine,
  }

  @typedoc "Error types returned from Predicator.Evaluator"
  @type error_t :: {:error,
    InstructionError.t()
    | ValueError.t()
    | InstructionNotCompleteError.t() }

  @doc ~S"""
  Execute will evaluate a predicator instruction set.

  If your context struct is using string_keyed map then you will need to pass in the
  `[map_type: :string]` options to the execute function to evaluate.

  ### Examples:

  iex> Predicator.Evaluator.execute([["lit", true]])
  true

  iex> Predicator.Evaluator.execute([["lit", 2], ["lit", 3], ["comparator", "LT"]])
  true

  iex> Predicator.Evaluator.execute([["load", "age"], ["lit", 18], ["comparator", "GT"]], %{age: 19})
  true

  iex> Predicator.Evaluator.execute([["load", "name"], ["lit", "jrichocean"], ["comparator", "EQ"]], %{age: 19})
  {:error, %Predicator.ValueError{error: "Non valid load value to evaluate", instruction_pointer: 0, instructions: [["load", "name"], ["lit", "jrichocean"], ["comparator", "EQ"]], stack: [], opts: [map_type: :atom, nil_values: ["", nil]]}}

  iex> Predicator.Evaluator.execute([["load", "age"], ["lit", 18], ["comparator", "GT"]], %{"age" => 19}, [map_type: :string])
  true

  """
  @spec execute(list(), struct()|map()) :: boolean() | error_t
  def execute(inst, context \\ %{}, opts \\ [map_type: :string, nil_values: ["", nil]]) do
    inst
    |> Machine.new(context, opts)
    |> run
  end

  defp run(%Machine{stack: [head | _]}) when is_boolean(head), do: head
  defp run(%Machine{} = machine) do
    case Machine.step(machine) do
      %Machine{} = machine -> run(machine)
      {:error, _reason} = err -> err
    end
  end
end

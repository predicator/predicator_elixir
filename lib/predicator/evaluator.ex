defmodule Predicator.Evaluator do
  @moduledoc "Evaluator Module"
  alias Predicator.{
    InstructionNotCompleteError,
    Machine
  }

  @typedoc "Error types returned from Predicator.Evaluator"
  @type error_t ::
          {:error,
           InstructionError.t()
           | ValueError.t()
           | InstructionNotCompleteError.t()}

  def execute(%Machine{} = machine) do
    case Machine.step(machine) do
      %Machine{} = machine ->
        cond do
          Machine.complete?(machine) and is_boolean(Machine.peek(machine)) ->
            Machine.peek(machine)

          Machine.complete?(machine) ->
            InstructionNotCompleteError.inst_not_complete_error(machine)

          true ->
            execute(machine)
        end

      {:error, _reason} = err ->
        err
    end
  end

  @doc ~S"""
  Execute will evaluate a predicator instruction set.

  If your context struct is using string_keyed map then you will need to pass in the
  `[map_type: :string]` options to the execute function to evaluate.

  ### Examples:

  iex> Predicator.Evaluator.execute([["lit", true]])
  true

  iex> Predicator.Evaluator.execute([["lit", 2], ["lit", 3], ["compare", "LT"]])
  true

  iex> Predicator.Evaluator.execute([["load", "age"], ["lit", 18], ["compare", "GT"]], %{age: 19})
  true

  iex> Predicator.Evaluator.execute([["load", "name"], ["lit", "jrichocean"], ["compare", "EQ"]], %{age: 19})
  {:error, %Predicator.ValueError{error: "Non valid load value to evaluate", instruction_pointer: 0, instructions: [["load", "name"], ["lit", "jrichocean"], ["compare", "EQ"]], stack: [], opts: [map_type: :string, nil_values: ["", nil]]}}

  iex> Predicator.Evaluator.execute([["load", "age"], ["lit", 18], ["compare", "GT"]], %{"age" => 19}, [map_type: :string])
  true

  """
  @spec execute(list(), struct() | map()) :: boolean() | error_t
  def execute(inst, context \\ %{}, opts \\ [map_type: :string, nil_values: ["", nil]])
      when is_list(inst) do
    inst
    |> to_machine(context, opts)
    |> execute
  end

  def to_machine(instructions, context, opts) do
    Machine.new(instructions, context, opts)
  end
end

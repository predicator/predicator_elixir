defmodule Predicator.ValueError do
  @type t :: %__MODULE__{
    error: String.t(),
    instructions: list(),
    stack: list(),
    instruction_pointer: non_neg_integer()
  }

  defstruct [
    error: "Non valid load value to evaluate",
    value: nil,
    instructions: nil,
    stack: nil,
    instruction_pointer: nil
  ]
end

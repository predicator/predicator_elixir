defmodule Predicator.ValueError do
  @type t :: %__MODULE__{
    error: String.t(),
    instructions: list(),
    stack: list(),
    instruction_pointer: non_neg_integer(),
    opts: list()
  }

  defstruct [
    error: "Non valid load value to evaluate",
    instructions: nil,
    stack: nil,
    instruction_pointer: nil,
    opts: nil
  ]
end

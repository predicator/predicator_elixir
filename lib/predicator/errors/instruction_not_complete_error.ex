defmodule Predicator.InstructionNotCompleteError do
  @moduledoc """
  Error struct returned by Instruction Not Complete Error.

    iex> %Predicator.InstructionNotCompleteError{}
    %Predicator.InstructionNotCompleteError{error: "Instruction must have evaluation rule after a type conversion", instructions: nil, predicate: nil, instruction_pointer: nil}
  """
  @type t :: %__MODULE__{
    error: String.t(),
    instructions: list(),
    predicate: String.t(),
    instruction_pointer: non_neg_integer(),
    opts: list()
  }

  defstruct [
    error: "Instruction must have evaluation rule after a type conversion",
    instructions: nil,
    predicate: nil,
    instruction_pointer: nil,
    opts: nil
  ]
end

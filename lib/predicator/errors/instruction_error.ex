defmodule Predicator.InstructionError do
  @moduledoc """
  Error struct returned by Value Error Types.

    iex> %Predicator.InstructionError{}
    %Predicator.InstructionError{error: "Non valid predicate instruction", instructions: nil, predicate: nil, instruction_pointer: nil}
  """
  @type t :: %__MODULE__{
    error: String.t(),
    instructions: list(),
    predicate: String.t(),
    instruction_pointer: non_neg_integer(),
    opts: list()
  }

  defstruct [
    error: "Non valid predicate instruction",
    instructions: nil,
    predicate: nil,
    instruction_pointer: nil,
    opts: nil
  ]
end

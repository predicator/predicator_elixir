defmodule Predicator.ValueError do
  @moduledoc """
  Error struct returned by Value Error Types.

    iex> %Predicator.ValueError{}
    %Predicator.ValueError{error: "Non valid load value to evaluate", instructions: nil, stack: nil, instruction_pointer: nil}
  """
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

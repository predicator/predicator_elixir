defmodule Predicator.InstructionError do
  @moduledoc """
  Error struct returned by Value Error Types.

    iex> %Predicator.InstructionError{}
    %Predicator.InstructionError{error: "Non valid predicate instruction", instructions: nil, predicate: nil, instruction_pointer: nil, stack: nil}
  """
  @type t :: %__MODULE__{
    error: String.t(),
    instructions: list(),
    predicate: String.t(),
    stack: list(),
    instruction_pointer: non_neg_integer(),
    opts: list()
  }

  defstruct [
    error: "Non valid predicate instruction",
    instructions: nil,
    predicate: nil,
    stack: nil,
    instruction_pointer: nil,
    opts: nil
  ]

  @spec instruction_error(Predicator.Machine.t, term) :: {:error, t}
  def instruction_error(machine=%Predicator.Machine{}, predicate) do
    {:error, %__MODULE__{
      instructions: machine.instructions,
      predicate: predicate,
      stack: machine.stack,
      instruction_pointer: machine.ip,
      opts: machine.opts
      }
    }
  end
end

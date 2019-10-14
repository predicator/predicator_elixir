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

  @spec value_error(Predicator.Machine.t) :: {:error, t}
  def value_error(machine=%Predicator.Machine{}) do
    {:error, %__MODULE__{
        stack: machine.stack,
        instructions: machine.instructions,
        instruction_pointer: machine.instruction_pointer,
        opts: machine.opts
      }
    }
  end
end

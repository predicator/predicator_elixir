defmodule Predicator.Errors do
  @moduledoc false
  alias Predicator.{
    ValueError,
    InstructionError,
    InstructionNotCompleteError
  }

  def _value_error(machine=%Machine{}) do
    {:error, %ValueError{
        stack: machine.stack,
        instructions: machine.instructions,
        instruction_pointer: machine.ip,
        opts: machine.opts
      }
    }
  end

  def _instruction_error(machine=%Machine{}, predicate) do
    {:error, %InstructionError{
      predicate: predicate,
      instructions: machine.instructions,
      instruction_pointer: machine.ip,
      opts: machine.opts
      }
    }
  end

  def _inst_not_complete_error(machine=%Machine{}) do
    {:error, %InstructionNotCompleteError{
      stack: machine.stack,
      instructions: machine.instructions,
      instruction_pointer: machine.ip,
      opts: machine.opts
      }
    }
  end
end

defmodule Machine do
  @moduledoc """
  A Machine Struct is comprised of the instructions set, the current stack, the instruction pointer and the context struct.
  """
  defstruct instructions: [], stack: [], ip: 0, context_struct: nil

  @type t :: %Machine{
    instructions: [] | [...],
    stack: [] | [...],
    ip: non_neg_integer(),
    context_struct: struct() | map()
  }
end

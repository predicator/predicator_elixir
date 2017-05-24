defmodule Machine do
  defstruct instructions: [], stack: [], ip: 0, context_struct: nil

  @type t :: %Machine{
    instructions: [] | [...],
    stack: [] | [...],
    ip: non_neg_integer(),
    context_struct: struct() | nil
  }
end

defmodule Predicator.Machine do
  @moduledoc """
  A Machine Struct is comprised of the instructions set, the current stack, the instruction pointer and the context struct.

    iex>%Predicator.Machine{}
    %Predicator.Machine{instructions: [], stack: [], ip: 0, context_struct: nil, opts: []}
  """
  defstruct [
    instructions: [],
    stack: [],
    ip: 0,
    context_struct: nil,
    opts: []
  ]

  @type t :: %__MODULE__{
    instructions: [] | [...],
    stack: [] | [...],
    ip: non_neg_integer(),
    context_struct: struct() | map(),
    opts: [{atom, atom}, ...] | [{atom, [...]}, ...]
  }
end

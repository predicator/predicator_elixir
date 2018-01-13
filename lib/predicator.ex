defmodule Predicator do
  @moduledoc """
  Documentation for Predicator.
  """
  import Predicator.Evaluator

  def eval(instructions, context_struct \\ %{}, opts \\ [map_type: :atom]),
    do: execute(instructions, context_struct, opts)

end

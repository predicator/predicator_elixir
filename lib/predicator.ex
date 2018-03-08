defmodule Predicator do
  @moduledoc """
  Documentation for Predicator.
  """
  alias Predicator.Evaluator

  def eval(instructions, context_struct \\ %{}, opts \\ [map_type: :atom]),
    do: Evaluator.execute(instructions, context_struct, opts)

end

defmodule Evaluator do
  defstruct instructions: [], stack: [], ip: 0, context_struct: nil

  # inst = [["lit", 30], ["lit", 432], ["compare", "GT"]]
  # inst = [["lit", true]]

  @doc """
  execute/2 takes an instruction set and context struct
  """
  def execute(inst, context_struct \\ %{}) do
    machine = %Evaluator{instructions: inst, context_struct: context_struct}
    _execute(get_instruction(machine), machine)
  end

  defp _execute(nil, machine) do
    # IO.inspect(machine.stack)
    hd(machine.stack)
  end

  defp _execute(["lit"|[val|_]], machine=%Evaluator{}) do
    machine = %Evaluator{ machine |
      stack: [val|machine.stack],
      ip: machine.ip + 1
    }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["not"|_], machine=%Evaluator{}) do
    val = machine.stack |> List.pop_at(0)
    machine = %Evaluator{ machine |
      stack: [!val|machine.stack],
      ip: machine.ip + 1
    }
    _execute(get_instruction(machine), machine)
  end

  # Equals Comparison
  defp _execute(["compare"|["EQ"|_]], machine=%Evaluator{stack: [left|[right|rest_of_stack]]})
    when is_nil(left) != nil
    when is_nil(right) != nil do
      val = left == right
      machine = %Evaluator{machine | stack: [val|rest_of_stack], ip: machine.ip + 1 }
      _execute(get_instruction(machine), machine)
  end
  defp _execute(["compare"|["EQ"|_]], machine) do
    machine = %Evaluator{machine| stack: [false| machine.stack]}
    _execute(get_instruction(machine), machine)
  end

  # Greater Than
  defp _execute(["compare"|["GT"|_]], machine=%Evaluator{stack: [second|[first|rest_of_stack]]})
    when is_nil(second) != nil
    when is_nil(first) != nil do
      val = first > second
      machine = %Evaluator{ machine | stack: [val|machine.stack], ip: machine.ip + 1 }
      _execute(get_instruction(machine), machine)
  end
  defp _execute(["compare"|["GT"|_]], machine) do
    machine = %Evaluator{machine| stack: [false| machine.stack]}
    _execute(get_instruction(machine), machine)
  end

  # Load lit
  defp _execute(["load"|[val|_]], machine=%Evaluator{}) do
    val = String.to_atom(val)
    user_key = Map.get(machine.context_struct, val)
    machine = %Evaluator{ machine | stack: [user_key|machine.stack], ip: machine.ip + 1 }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["jfalse"|[offset|_]], machine=%Evaluator{}) do
    machine =
    case hd(machine.stack) do
      false ->
        %Evaluator{machine| ip: machine.ip + offset}
      _ ->
        %Evaluator{machine| stack: tl(machine.stack), ip: machine.ip + 1}
    end
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["jtrue"|[offset|_]], machine=%Evaluator{}) do
    machine =
    case hd(machine.stack) do
      true ->
        %Evaluator{machine| ip: machine.ip + offset}
      _ ->
        %Evaluator{machine| stack: tl(machine.stack), ip: machine.ip + 1}
    end
    _execute(get_instruction(machine), machine)
  end

  defp get_instruction(machine=%Evaluator{}) do
    case machine.ip < Enum.count(machine.instructions) do
      true ->
        Enum.at(machine.instructions, machine.ip)
      _ ->
        nil
    end
  end
end

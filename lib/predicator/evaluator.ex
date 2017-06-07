defmodule Evaluator do
  @doc """
  execute/2 takes an instruction set and context struct

  Example instructions sets:

    inst = [["lit", true]]

    inst = [["lit", 30], ["lit", 432], ["compare", "GT"]]

    inst = [["lit", false], ["jtrue", 4], ["lit", 1], ["lit", 1], ["compare", "EQ"]]
  """

  @spec execute(list(), struct()|map()) :: Machine.t()
  def execute(inst, context_struct \\ %{}) do
    machine = %Machine{instructions: inst, context_struct: context_struct}
    _execute(get_instruction(machine), machine)
  end

  defp _execute(nil, machine) do
    hd(machine.stack)
  end

  defp _execute(["lit"|[val|_]], machine=%Machine{}) do
    machine = %Machine{ machine | stack: [val|machine.stack], ip: machine.ip + 1 }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["not"|_], machine=%Machine{stack: [val|rest_of_stack]}) do
    machine = %Machine{ machine | stack: [!val|machine.stack], ip: machine.ip + 1 }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["compare"|["EQ"|_]], machine=%Machine{stack: [left|[right|rest_of_stack]]})
    when is_nil(left) != nil
    when is_nil(right) != nil do
      val = left == right
      machine = %Machine{ machine | stack: [val|rest_of_stack], ip: machine.ip + 1 }
      _execute(get_instruction(machine), machine)
  end
  defp _execute(["compare"|["EQ"|_]], machine) do
    machine = %Machine{ machine| stack: [false| machine.stack] }
    _execute(get_instruction(machine), machine)
  end
  defp _execute(["compare"|["GT"|_]], machine=%Machine{stack: [second|[first|rest_of_stack]]})
    when is_nil(second) != nil
    when is_nil(first) != nil do
      val = first > second
      machine = %Machine{ machine | stack: [val|machine.stack], ip: machine.ip + 1 }
      _execute(get_instruction(machine), machine)
  end
  defp _execute(["compare"|["GT"|_]], machine) do
    machine = %Machine{ machine| stack: [false| machine.stack] }
    _execute(get_instruction(machine), machine)
  end

  # [["lit", 2], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]
  defp _execute(["compare"|["BETWEEN"|_]], machine=%Machine{stack: [max|[min|[val|rest_of_stack]]]}) do
    res = Enum.member?(min..max, val)
    machine = %Machine{ machine| stack: [res|rest_of_stack], ip: machine.ip + 1 }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["load"|[val|_]], machine=%Machine{}) do
    user_key = Map.get(machine.context_struct, String.to_atom(val))
    machine = %Machine{ machine | stack: [user_key|machine.stack], ip: machine.ip + 1 }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["jfalse"|[offset|_]], machine=%Machine{}) do
    machine =
    case hd(machine.stack) do
      false ->
        %Machine{machine| ip: machine.ip + offset}
      _ ->
        %Machine{machine| stack: tl(machine.stack), ip: machine.ip + 1}
    end
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["jtrue"|[offset|_]], machine=%Machine{}) do
    machine =
    case hd(machine.stack) do
      true ->
        %Machine{machine| ip: machine.ip + offset}
      _ ->
        %Machine{machine| stack: tl(machine.stack), ip: machine.ip + 1}
    end
    _execute(get_instruction(machine), machine)
  end

  defp get_instruction(machine=%Machine{}) do
    # IO.inspect(machine.stack)
    case machine.ip < Enum.count(machine.instructions) do
      true -> Enum.at(machine.instructions, machine.ip)
      _ -> nil
    end
  end
end

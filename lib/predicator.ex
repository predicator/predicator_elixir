defmodule Evaluator do
  defstruct instructions: [], stack: [], ip: 0

  # inst = [["lit", 30], ["lit", 432], ["compare", "GT"]]
  # inst = [["lit", true]]

  def execute(inst) do
    machine = Map.put(%Evaluator{}, :instructions, inst)
    _execute(get_instruction(machine), machine)
  end

  defp _execute(nil, machine) do
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

  defp _execute(["compare"|["EQ"|_]], machine=%Evaluator{}) do
    [left|[right|stack]] = machine.stack
    val = left == right
    machine = %Evaluator{ machine |
      stack: [val|stack],
      ip: machine.ip + 1
    }
    _execute(get_instruction(machine), machine)
  end

  defp get_instruction(machine=%Evaluator{}) do
    if machine.ip < Enum.count(machine.instructions) do
      Enum.at(machine.instructions, machine.ip)
    else
      nil
    end
  end
end



defmodule Predicator do
  @moduledoc """
  Documentation for Predicator.
  """

end

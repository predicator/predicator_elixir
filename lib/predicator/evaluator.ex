defmodule Predicator.Evaluator do
  alias Predicator.Machine
  alias Predicator.{
    InstructionError,
    ValueError,
  }

  @doc """
  execute/2 takes an instruction set and context struct

  Example instructions sets:

    iex> execute([["lit", true]])
    true

    iex> Predicator.Evaluator.execute([["load", "age"], ["lit", 18], ["compare", "GT"]], %{age: 19})
    true

    iex> Predicator.Evaluator.execute([["load", "name"], ["lit", "jrichocean"], ["compare", "EQ"]], %{age: 19})
    {:error, %Predicator.ValueError{error: "Non valid load value to evaluate", instruction_pointer: 0, instructions: [["load", "name"], ["lit", "jrichocean"], ["compare", "EQ"]], stack: []}}
  """
  @spec execute(list(), struct()|map()) :: boolean() | {:error, InstructionError.t()|ValueError.t()}
  def execute(inst, context_struct \\ %{}) do
    machine = %Machine{instructions: inst, context_struct: context_struct}
    _execute(get_instruction(machine), machine)
  end

  defp _execute(nil, machine), do: hd(machine.stack)

  defp _execute(["array"|[val|_]], machine=%Machine{}) do
    machine = %Machine{ machine | stack: [val|machine.stack], ip: machine.ip + 1 }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["lit"|[val|_]], machine=%Machine{}) do
    machine = %Machine{ machine | stack: [val|machine.stack], ip: machine.ip + 1 }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["not"|_], machine=%Machine{stack: [val|rest_of_stack]}) do
    machine = %Machine{ machine | stack: [!val|machine.stack], ip: machine.ip + 1 }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["compare"|["EQ"|_]], machine=%Machine{stack: [left|[right|rest_of_stack]]}) do
      val = left == right
      machine = %Machine{ machine | stack: [val|rest_of_stack], ip: machine.ip + 1 }
      _execute(get_instruction(machine), machine)
  end
  defp _execute(["compare"|["EQ"|_]], machine) do
    machine = %Machine{ machine| stack: [false| machine.stack] }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["compare"|["IN"|_]], machine=%Machine{stack: [left|[right|rest_of_stack]]}) do
      val = Enum.member?(left, right)
      machine = %Machine{ machine | stack: [val|rest_of_stack], ip: machine.ip + 1 }
      _execute(get_instruction(machine), machine)
  end
  defp _execute(["compare"|["IN"|_]], machine) do
    machine = %Machine{ machine| stack: [false| machine.stack] }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["compare"|["NOTIN"|_]], machine=%Machine{stack: [left|[right|rest_of_stack]]}) do
      val = !Enum.member?(left, right)
      machine = %Machine{ machine | stack: [val|rest_of_stack], ip: machine.ip + 1 }
      _execute(get_instruction(machine), machine)
  end
  defp _execute(["compare"|["NOTIN"|_]], machine) do
    machine = %Machine{ machine| stack: [false| machine.stack] }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["compare"|["GT"|_]], machine=%Machine{stack: [second|[first|rest_of_stack]]}) do
      val = first > second
      machine = %Machine{ machine | stack: [val|machine.stack], ip: machine.ip + 1 }
      _execute(get_instruction(machine), machine)
  end
  defp _execute(["compare"|["GT"|_]], machine) do
    machine = %Machine{ machine| stack: [false| machine.stack] }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["compare"|["LT"|_]], machine=%Machine{stack: [second|[first|rest_of_stack]]}) do
      val = first < second
      machine = %Machine{ machine | stack: [val|machine.stack], ip: machine.ip + 1 }
      _execute(get_instruction(machine), machine)
  end
  defp _execute(["compare"|["LT"|_]], machine) do
    machine = %Machine{ machine| stack: [false| machine.stack] }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["compare"|["BETWEEN"|_]], machine=%Machine{stack: [max|[min|[val|rest_of_stack]]]}) do
    res = Enum.member?(min..max, val)
    machine = %Machine{ machine| stack: [res|rest_of_stack], ip: machine.ip + 1 }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["load"|[val|_]], machine=%Machine{}) do
    case Map.get(machine.context_struct, String.to_atom(val)) do
      nil ->
        {:error,
          %ValueError{
            stack: machine.stack,
            instructions: machine.instructions,
            instruction_pointer: machine.ip
          }
        }
      user_key ->
        machine = %Machine{ machine | stack: [user_key|machine.stack], ip: machine.ip + 1 }
        _execute(get_instruction(machine), machine)
    end
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

  defp _execute([non_recognized_predicate|_], machine=%Machine{}) do
    error = %InstructionError{
      predicate: non_recognized_predicate,
      instructions: machine.instructions,
      instruction_pointer: machine.ip
    }
    {:error, error}
  end

  defp get_instruction(machine=%Machine{}) do
    # IO.inspect(machine.stack)
    case machine.ip < Enum.count(machine.instructions) do
      true -> Enum.at(machine.instructions, machine.ip)
      _ -> nil
    end
  end
end

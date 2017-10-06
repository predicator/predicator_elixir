defmodule Predicator.Evaluator do
  @moduledoc """
  Evaluator module
  """
  alias Predicator.Machine
  alias Predicator.{
    InstructionError,
    ValueError,
  }

  @doc """
  execute/1 takes an instruction set and evaluates

  Example:

    iex> execute([["lit", true]])
    true

    iex> execute([["lit", 2], ["lit", 3], ["compare", "LT"]])
    true

  execute/2 takes an instruction set and context struct

  Example:

    iex> Predicator.Evaluator.execute([["load", "age"], ["lit", 18], ["compare", "GT"]], %{age: 19})
    true

    iex> Predicator.Evaluator.execute([["load", "name"], ["lit", "jrichocean"], ["compare", "EQ"]], %{age: 19})
    {:error, %Predicator.ValueError{error: "Non valid load value to evaluate", instruction_pointer: 0, instructions: [["load", "name"], ["lit", "jrichocean"], ["compare", "EQ"]], stack: [], opts: [map_type: :atom]}}

  execute/3 takes an additional keyword_list set of options.

  Example:

    iex> Predicator.Evaluator.execute([["load", "age"], ["lit", 18], ["compare", "GT"]], %{"age" => 19}, [map_type: :string])
    true

  """
  @spec execute(list(), struct()|map()) :: boolean() | {:error, InstructionError.t()|ValueError.t()}
  def execute(inst, context_struct \\ %{}, opts \\ [map_type: :atom]) do
    machine = %Machine{instructions: inst, context_struct: context_struct, opts: opts}
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

  defp _execute(["not"|_], machine=%Machine{stack: [val|_rest_of_stack]}) do
    machine = %Machine{ machine | stack: [!val|machine.stack], ip: machine.ip + 1 }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["to_bool"|_], machine=%Machine{stack: [loaded_val|_]})
    when loaded_val in ["true", "false"] do
    machine = %Machine{machine| stack: [String.to_existing_atom(loaded_val)], ip: machine.ip + 1 }
    _execute(get_instruction(machine), machine)
  end
  defp _execute(["to_bool"|_], machine=%Machine{stack: [loaded_val|_]}) when is_boolean(loaded_val) do
    machine = %Machine{machine| stack: [loaded_val], ip: machine.ip + 1 }
    _execute(get_instruction(machine), machine)
  end
  defp _execute(["to_bool"|_], machine=%Machine{}), do: value_error(machine)

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

  defp _execute(["compare"|["GT"|_]], machine=%Machine{stack: [second|[first|_rest_of_stack]]}) do
      val = first > second
      machine = %Machine{ machine | stack: [val|machine.stack], ip: machine.ip + 1 }
      _execute(get_instruction(machine), machine)
  end
  defp _execute(["compare"|["GT"|_]], machine) do
    machine = %Machine{ machine| stack: [false| machine.stack] }
    _execute(get_instruction(machine), machine)
  end

  defp _execute(["compare"|["LT"|_]], machine=%Machine{stack: [second|[first|_rest_of_stack]]}) do
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

  defp _execute(["load"|[val|_]], machine=%Machine{opts: [map_type: :string]}) do
    case Map.get(machine.context_struct, val) do
      nil -> value_error(machine)
      user_key ->
        machine = %Machine{ machine | stack: [user_key|machine.stack], ip: machine.ip + 1 }
        _execute(get_instruction(machine), machine)
    end
  end

  defp _execute(["load"|[val|_]], machine=%Machine{}) do
    case Map.get(machine.context_struct, String.to_existing_atom(val)) do
      nil -> value_error(machine)
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

  defp _execute([non_recognized_predicate|_], machine=%Machine{}), do: instruction_error(machine, non_recognized_predicate)

  defp get_instruction(machine=%Machine{}) do
    case machine.ip < Enum.count(machine.instructions) do
      true -> Enum.at(machine.instructions, machine.ip)
      _ -> nil
    end
  end

  def value_error(machine=%Machine{}) do
    {:error, %ValueError{
        stack: machine.stack,
        instructions: machine.instructions,
        instruction_pointer: machine.ip,
        opts: machine.opts
      }
    }
  end

  def instruction_error(machine=%Machine{}, predicate) do
    {:error, %InstructionError{
      predicate: predicate,
      instructions: machine.instructions,
      instruction_pointer: machine.ip,
      opts: machine.opts
      }
    }
  end

end

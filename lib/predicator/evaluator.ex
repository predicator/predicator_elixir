defmodule Predicator.Evaluator do
  @moduledoc "Evaluator Module"
  alias Predicator.Machine
  import Predicator.Errors

  @type error_t :: {:error,
    InstructionError.t()
    | ValueError.t()
    | InstructionNotCompleteError.t() }

  @doc ~S"""
  Execute will evaluate a predicator instruction set.

  If your context struct is using string_keyed map then you will need to pass in the
  `[map_type: :string]` options to the execute function to evaluate.

  ### Examples:

      iex> Predicator.Evaluator.execute([["lit", true]])
      true

      iex> Predicator.Evaluator.execute([["lit", 2], ["lit", 3], ["compare", "LT"]])
      true

      iex> Predicator.Evaluator.execute([["load", "age"], ["lit", 18], ["compare", "GT"]], %{age: 19})
      true

      iex> Predicator.Evaluator.execute([["load", "name"], ["lit", "jrichocean"], ["compare", "EQ"]], %{age: 19})
      {:error, %Predicator.ValueError{error: "Non valid load value to evaluate", instruction_pointer: 0, instructions: [["load", "name"], ["lit", "jrichocean"], ["compare", "EQ"]], stack: [], opts: [map_type: :atom, nil_values: ["", nil]]}}

      iex> Predicator.Evaluator.execute([["load", "age"], ["lit", 18], ["compare", "GT"]], %{"age" => 19}, [map_type: :string])
      true

  """
  @spec execute(list(), struct()|map()) :: boolean() | error_t
  def execute(inst, context_struct \\ %{}, opts \\ [map_type: :atom, nil_values: ["", nil]]) do
    machine = %Machine{instructions: inst, context_struct: context_struct, opts: opts}
    _execute(_get_instruction(machine), machine)
  end

  def _execute(nil, m = %Machine{stack: [first|_]}) when not is_boolean(first), do: _inst_not_complete_error(m)
  def _execute(nil, machine), do: hd(machine.stack)

  def _execute(["array"|[val|_]], machine=%Machine{}) do
    machine = %Machine{ machine | stack: [val|machine.stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end

  def _execute(["lit"|[val|_]], machine=%Machine{}) do
    machine = %Machine{ machine | stack: [val|machine.stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end

  def _execute(["not"|_], machine=%Machine{stack: [val|_rest_of_stack]}) do
    machine = %Machine{ machine | stack: [!val|machine.stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end

  # Conversion Predicates
  def _execute(["to_bool"|_], machine=%Machine{stack: [val|rest_of_stack]}) when val in ["true", "false"] do
    machine = %Machine{machine| stack: [String.to_existing_atom(val)|rest_of_stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end
  def _execute(["to_bool"|_], machine=%Machine{stack: [val|rest_of_stack]}) when is_boolean(val) do
    machine = %Machine{machine| stack: [val|rest_of_stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end
  def _execute(["to_bool"|_], machine=%Machine{}), do: _value_error(machine)

  def _execute(["to_str"|_], machine=%Machine{stack: [val|rest_of_stack]}) when is_nil(val) do
    machine = %Machine{machine| stack: ["nil"|rest_of_stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end
  def _execute(["to_str"|_], machine=%Machine{stack: [val|rest_of_stack]}) do
    machine = %Machine{machine| stack: [to_string(val)|rest_of_stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end

  def _execute(["to_int"|_], machine=%Machine{stack: [val|rest_of_stack]}) when is_binary(val) do
    case Integer.parse(val) do
      {integer, _} ->
        machine = %Machine{machine| stack: [integer|rest_of_stack], ip: machine.ip + 1 }
        _execute(_get_instruction(machine), machine)
      :error -> _value_error(machine)
    end
  end
  def _execute(["to_int"|_], machine=%Machine{stack: [val|rest_of_stack]}) when is_integer(val) do
    m = %Machine{machine| stack: [val|rest_of_stack], ip: machine.ip + 1 }
    _execute(_get_instruction(m), m)
  end


  def _execute(inst=["to_date"|_], machine=%Machine{}),
    do: Predicator.Evaluator.Date._execute(inst, machine)

  def _execute(inst=["date_ago"|_], machine=%Machine{}),
    do: Predicator.Evaluator.Date._execute(inst, machine)

  def _execute(inst=["date_from_now"|_], machine=%Machine{}),
    do: Predicator.Evaluator.Date._execute(inst, machine)


  def _execute(["blank"], machine=%Machine{stack: [val|rest_of_stack], opts: opts}) do
    machine = case Enum.member?(opts[:nil_values], val) do
      true ->
        %Machine{machine| stack: [true|rest_of_stack], ip: machine.ip + 1 }
      false ->
        %Machine{machine| stack: [false|rest_of_stack], ip: machine.ip + 1 }
    end
    _execute(_get_instruction(machine), machine)
  end

  def _execute(["present"], machine=%Machine{stack: [val|rest_of_stack], opts: opts}) do
    machine = case Enum.member?(opts[:nil_values], val) do
      true ->
        %Machine{machine| stack: [false|rest_of_stack], ip: machine.ip + 1 }
      false ->
        %Machine{machine| stack: [true|rest_of_stack], ip: machine.ip + 1 }
    end
    _execute(_get_instruction(machine), machine)
  end

  def _execute(["compare"|["EQ"|_]], machine=%Machine{stack: [left|[right|rest_of_stack]]}) do
    val = left == right
    machine = %Machine{ machine | stack: [val|rest_of_stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end
  def _execute(["compare"|["EQ"|_]], machine) do
    machine = %Machine{ machine| stack: [false| machine.stack] }
    _execute(_get_instruction(machine), machine)
  end

  def _execute(["compare"|["IN"|_]], machine=%Machine{stack: [left|[right|rest_of_stack]]}) do
    val = Enum.member?(left, right)
    machine = %Machine{ machine | stack: [val|rest_of_stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end
  def _execute(["compare"|["IN"|_]], machine) do
    machine = %Machine{ machine| stack: [false| machine.stack] }
    _execute(_get_instruction(machine), machine)
  end

  def _execute(["compare"|["NOTIN"|_]], machine=%Machine{stack: [left|[right|rest_of_stack]]}) do
    val = !Enum.member?(left, right)
    machine = %Machine{ machine | stack: [val|rest_of_stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end
  def _execute(["compare"|["NOTIN"|_]], machine) do
    machine =
      %Machine{ machine| stack: [false| machine.stack] }
      |> _get_instruction()
      |> _execute(machine)
  end

  def _execute(["compare"|["GT"|_]], machine=%Machine{stack: [second|[first|_rest_of_stack]]}) do
    val = first > second
    machine = %Machine{ machine | stack: [val|machine.stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end
  def _execute(["compare"|["GT"|_]], machine) do
    machine = %Machine{ machine| stack: [false| machine.stack] }
    _execute(_get_instruction(machine), machine)
  end

  def _execute(["compare"|["LT"|_]], machine=%Machine{stack: [second|[first|_rest_of_stack]]}) do
    val = first < second
    machine = %Machine{ machine | stack: [val|machine.stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end
  def _execute(["compare"|["LT"|_]], machine) do
    machine = %Machine{ machine| stack: [false| machine.stack] }
    _execute(_get_instruction(machine), machine)
  end

  def _execute(["compare"|["BETWEEN"|_]], machine=%Machine{stack: [max|[min|[val|rest_of_stack]]]}) do
    res = Enum.member?(min..max, val)
    machine = %Machine{ machine| stack: [res|rest_of_stack], ip: machine.ip + 1 }
    _execute(_get_instruction(machine), machine)
  end

  def _execute(["load"|[val|_]], machine=%Machine{opts: [map_type: :string]}) do
    case Map.get(machine.context_struct, val, :nokey) do
      :nokey -> _value_error(machine)
      user_key ->
        machine = %Machine{ machine | stack: [user_key|machine.stack], ip: machine.ip + 1 }
        _execute(_get_instruction(machine), machine)
    end
  end
  def _execute(["load"|[val|_]], machine=%Machine{}) do
    case Map.get(machine.context_struct, String.to_existing_atom(val), :nokey) do
      :nokey -> _value_error(machine)
      user_key ->
        machine = %Machine{ machine | stack: [user_key|machine.stack], ip: machine.ip + 1 }
        _execute(_get_instruction(machine), machine)
    end
  end

  def _execute(["jfalse"|[offset|_]], machine=%Machine{}) do
    machine =
    case hd(machine.stack) do
      false -> %Machine{machine| ip: machine.ip + offset}
      _ -> %Machine{machine| stack: tl(machine.stack), ip: machine.ip + 1}
    end
    _execute(_get_instruction(machine), machine)
  end

  def _execute(["jtrue"|[offset|_]], machine=%Machine{}) do
    machine =
    case hd(machine.stack) do
      true -> %Machine{machine| ip: machine.ip + offset}
      _ -> %Machine{machine| stack: tl(machine.stack), ip: machine.ip + 1}
    end
    _execute(_get_instruction(machine), machine)
  end

  def _execute([non_recognized_predicate|_], machine=%Machine{}),
    do: _instruction_error(machine, non_recognized_predicate)

  def _get_instruction(machine=%Machine{}) do
    case machine.ip < Enum.count(machine.instructions) do
      true ->
        Enum.at(machine.instructions, machine.ip)
      _ -> nil
    end
  end
  # def _get_instruction(machine=%Machine{}) do
  # REFACTOR
  # end

end

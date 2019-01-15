defmodule Predicator.Machine do
  @moduledoc """
  A Machine Struct is comprised of the instructions set, the current stack, the instruction pointer and the context struct.

    iex>%Predicator.Machine{}
    %Predicator.Machine{instructions: [], stack: [], instruction_pointer: 0, context: nil, opts: []}
  """
  alias Predicator.{
    ValueError,
    InstructionError,
    InstructionNotCompleteError
  }

  defstruct [
    instructions: [],
    stack: [],
    instruction_pointer: 0,
    context: %{},
    opts: []
  ]

  @type t :: %__MODULE__{
    instructions: [] | [...],
    stack: [] | [...],
    instruction_pointer: non_neg_integer(),
    context: struct() | map(),
    opts: [{atom, atom}, ...] | [{atom, [...]}, ...]
  }

  def new(instructions, context, opts) do
    %__MODULE__{instructions: instructions, context: context, opts: opts}
  end

  def step(%__MODULE__{} = machine) do
    next_instruction = next_instruction(machine)
    accept_instruction(machine, next_instruction)
  end

  def put_instruction(%__MODULE__{} = machine, instruction, opts \\ []) do
    pointer =
      if Keyword.get(opts, :increment, true) do
        machine.instruction_pointer + 1
      else
        machine.instruction_pointer
      end

    %__MODULE__{ machine | stack: [instruction | machine.stack], instruction_pointer: pointer }
  end

  def next_instruction(%__MODULE__{} = machine) do
    case machine.instruction_pointer < Enum.count(machine.instructions) do
      true -> Enum.at(machine.instructions, machine.instruction_pointer)
      _ -> nil
    end
  end

  def increment_pointer(%__MODULE__{} = machine, amount) do
    %__MODULE__{machine | instruction_pointer: machine.instruction_pointer + amount}
  end

  def pop_instruction(%__MODULE__{} = machine) do
    %__MODULE__{ machine | stack: tl(machine.stack), instruction_pointer: machine.instruction_pointer + 1 }
  end

  def load!(%__MODULE__{} = machine, key) when is_atom(key) do
    load!(machine, Atom.to_string(key))
  end

  def load!(%__MODULE__{context: context} = machine, key) when is_binary(key) do
    if has_variable?(machine, key) do
      Map.get(context, key)
    else
      ValueError.value_error(machine)
    end
  end

  def has_variable?(%__MODULE__{context: context}, key) when is_binary(key) do
    Map.has_key?(context, key)
  end

  def has_variable?(%__MODULE__{context: context}, key) when is_atom(key) do
    Map.has_key?(context, Atom.to_string(key))
  end

  def accept_instruction(m = %__MODULE__{stack: [first|_]}, nil)
  when not is_boolean(first), do: InstructionNotCompleteError.inst_not_complete_error(m)
  def accept_instruction(machine, nil), do: hd(machine.stack)

  def accept_instruction(machine = %__MODULE__{}, ["array"|[val|_]]) do
    put_instruction(machine, val)
  end

  def accept_instruction(machine = %__MODULE__{}, ["lit"|[val|_]]) do
    put_instruction(machine, val)
  end

  def accept_instruction(machine = %__MODULE__{stack: [val|_rest_of_stack]}, ["not"|_]) do
    put_instruction(machine, val)
  end

  # Conversion Predicates
  def accept_instruction(machine = %__MODULE__{stack: [val|_rest_of_stack]}, ["to_bool"|_]) when val in ["true", "false"] do
    put_instruction(machine, val)
  end
  def accept_instruction(machine = %__MODULE__{stack: [val|_rest_of_stack]}, ["to_bool"|_]) when is_boolean(val) do
    put_instruction(machine, val)
  end
  def accept_instruction(machine = %__MODULE__{}, ["to_bool"|_]), do: ValueError.value_error(machine)

  def accept_instruction(machine = %__MODULE__{stack: [val|_rest_of_stack]}, ["to_str"|_]) when is_nil(val) do
    put_instruction(machine, val)
  end
  def accept_instruction(machine = %__MODULE__{stack: [val|_rest_of_stack]}, ["to_str"|_]) do
    put_instruction(machine, val)
  end

  def accept_instruction(machine = %__MODULE__{stack: [val|_rest_of_stack]}, ["to_int"|_]) when is_binary(val) do
    case Integer.parse(val) do
      {integer, _} ->
        put_instruction(machine, integer)

      :error ->
        ValueError.value_error(machine)
    end
  end
  def accept_instruction(machine = %__MODULE__{stack: [val|_rest_of_stack]}, ["to_int"|_]) when is_integer(val) do
    put_instruction(machine, val)
  end

  def accept_instruction(machine = %__MODULE__{}, inst=["to_date"|_]),
  do: Predicator.Evaluator.Date._execute(inst, machine)

  def accept_instruction(machine = %__MODULE__{}, inst=["date_ago"|_]),
  do: Predicator.Evaluator.Date._execute(inst, machine)

  def accept_instruction(machine = %__MODULE__{}, inst=["date_from_now"|_]),
  do: Predicator.Evaluator.Date._execute(inst, machine)


  def accept_instruction(machine = %__MODULE__{stack: [val|_rest_of_stack], opts: opts}, ["blank"]) do
    val = Enum.member?(opts[:nil_values], val)
    put_instruction(machine, val)
  end

  def accept_instruction(machine = %__MODULE__{stack: [val|_rest_of_stack], opts: opts}, ["present"]) do
    val = !(Enum.member?(opts[:nil_values], val))
    put_instruction(machine, val)
  end

  def accept_instruction(machine = %__MODULE__{stack: [left|[right|_rest_of_stack]]}, ["comparator"|["EQ"|_]]) do
    put_instruction(machine, left == right)
  end
  def accept_instruction(machine, ["comparator"|["EQ"|_]]) do
    put_instruction(machine, false, increment: false)
  end

  def accept_instruction(machine = %__MODULE__{stack: [left|[right|_rest_of_stack]]}, ["comparator"|["IN"|_]]) do
    val = Enum.member?(left, right)
    put_instruction(machine, val)
  end
  def accept_instruction(machine, ["comparator"|["IN"|_]]) do
    put_instruction(machine, false, increment: false)
  end

  def accept_instruction(machine = %__MODULE__{stack: [left|[right|_rest_of_stack]]}, ["comparator"|["NOTIN"|_]]) do
    val = !Enum.member?(left, right)
    put_instruction(machine, val)
  end
  def accept_instruction(machine, ["comparator"|["NOTIN"|_]]) do
    put_instruction(machine, false, increment: false)
  end

  def accept_instruction(machine = %__MODULE__{stack: [second|[first|_rest_of_stack]]}, ["comparator"|["GT"|_]]) do
    put_instruction(machine, first > second)
  end
  def accept_instruction(machine, ["comparator"|["GT"|_]]) do
    put_instruction(machine, false, increment: false)
  end

  def accept_instruction(machine = %__MODULE__{stack: [second|[first|_rest_of_stack]]}, ["comparator"|["LT"|_]]) do
    put_instruction(machine, first < second)
  end
  def accept_instruction(machine, ["comparator"|["LT"|_]]) do
    put_instruction(machine, false, increment: false)
  end

  def accept_instruction(
    machine = %__MODULE__{stack: [max=%DateTime{}|[min=%DateTime{}|[val=%DateTime{}|_rest_of_stack]]]}, ["comparator"|["BETWEEN"|_]]
  ) do
    is_between =
      with :gt <- DateTime.compare(max, val),
           :lt <- DateTime.compare(min, val)
      do
        true
      else
        _ -> false
      end

    put_instruction(machine, is_between)
  end
  def accept_instruction(machine = %__MODULE__{stack: [max|[min|[val|_rest_of_stack]]]}, ["comparator"|["BETWEEN"|_]]) do
    put_instruction(machine, val in min..max)
  end

  def accept_instruction(machine = %__MODULE__{stack: [match|[stack_val|_rest_of_stack]]}, ["comparator"|["STARTSWITH"|_]]) do
    put_instruction(machine, String.starts_with?(stack_val, match))
  end

  def accept_instruction(machine = %__MODULE__{stack: [end_match|[stack_val|_rest_of_stack]]}, ["comparator"|["ENDSWITH"|_]]) do
    put_instruction(machine, String.ends_with?(stack_val, end_match))
  end

  def accept_instruction(machine = %__MODULE__{}, ["load"|[val|_]]) do
    if has_variable?(machine, val) do
      user_key = load!(machine, val)
      put_instruction(machine, user_key)
    else
      ValueError.value_error(machine)
    end
  end

  def accept_instruction(machine = %__MODULE__{}, ["jfalse"|[offset|_]]) do
    case hd(machine.stack) do
      false ->
        increment_pointer(machine, offset)
      _ ->
        pop_instruction(machine)
    end
  end

  def accept_instruction(machine = %__MODULE__{}, ["jtrue"|[offset|_]]) do
    case hd(machine.stack) do
      true ->
        increment_pointer(machine, offset)
      _ ->
        put_instruction(machine, tl(machine.stack))
    end
  end

  def accept_instruction(machine = %__MODULE__{}, [non_recognized_predicate|_]),
  do: InstructionError.instruction_error(machine, non_recognized_predicate)
end

defmodule Predicator.EvaluatorTest do
  use ExUnit.Case, async: false
  import Predicator.Evaluator
  doctest Predicator.Evaluator

  defmodule TestUser do
    defstruct [
      name: "Joshua",
      string_age: "29",
      age: 29,
      metalhead: "true",
      is_superhero: "falsse",
      nil_val: nil,
      blank_with_nil_options: "dog",
      true_val: true,
      false_val: false
    ]
  end


  describe "[\"lit\"] instruction" do
    test "true" do
      inst = [["lit", true]]
      assert execute(inst) == true
    end

    test "false" do
      inst = [["lit", false]]
      assert execute(inst) == false
    end

    test "lit NOT true" do
      inst = [["lit", true], ["not"]]
      assert execute(inst) == false
    end

    test "lit NOT false" do
      inst = [["lit", false], ["not"]]
      assert execute(inst) == true
    end
  end


  describe "[\"load\"] instruction" do
    test "true" do
      inst = [["load", "true_val"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "false" do
      inst = [["load", "false_val"]]
      assert execute(inst, %TestUser{}) == false
    end

    test "load NOT true" do
      inst = [["load", "true_val"], ["not"]]
      assert execute(inst, %TestUser{}) == false
    end

    test "load NOT false" do
      inst = [["load", "false_val"], ["not"]]
      assert execute(inst, %TestUser{}) == true
    end
  end


  describe "Errors" do
    test "InstructionNotCompleteError when coercion not followed by eval instuction" do
      inst1 = execute([["lit", 29],["to_str"]], %TestUser{})
      inst2 = execute([["lit", "29"],["to_int"]], %TestUser{})
      inst3 = execute([["lit", true],["to_bool"]], %TestUser{})
      inst4 = execute([["lit", "2010-01-31"],["to_date"]], %TestUser{})

      assert {:error, %Predicator.InstructionNotCompleteError{}} = inst1
      assert {:error, %Predicator.InstructionNotCompleteError{}} = inst2
      assert {:error, %Predicator.InstructionNotCompleteError{}} = inst3
      assert {:error, %Predicator.InstructionNotCompleteError{}} = inst4
    end

    test "InstructionError on invalid predicate op" do
      inst = [["blabla", 2345], ["something", 342]]
      assert execute(inst) == {:error, %Predicator.InstructionError{
        error: "Non valid predicate instruction",
        instructions: [["blabla", 2345], ["something", 342]],
        predicate: "blabla",
        instruction_pointer: 0,
        stack: [],
        opts: [map_type: :atom, nil_values: ["", nil]]
      }}
    end

    test "InstructionError correct instruction pointer on invalid predicate op" do
      inst = [["lit", 3], ["blabla", 2345]]
      assert execute(inst) == {:error, %Predicator.InstructionError{
        error: "Non valid predicate instruction",
        instructions: [["lit", 3], ["blabla", 2345]],
        predicate: "blabla",
        instruction_pointer: 1,
        stack: [3],
        opts: [map_type: :atom, nil_values: ["", nil]]
      }}
    end
  end

end

defmodule User do
  defstruct [name: "Joshua", age: 29, metalhead: "true", is_superhero: "falsse"]
end

defmodule PredicatorTest do
  use ExUnit.Case
  import Predicator.Evaluator


  test "execute/1 returns true" do
    inst = [["lit", true]]
    assert execute(inst) == true
  end

  test "execute/1 returns false" do
    inst = [["lit", false]]
    assert execute(inst) == false
  end

  test "execute/1 returns not true" do
    inst = [["lit", true], ["not"]]
    assert execute(inst) == false
  end

  test "execute/1 returns to_bool values" do
    inst = [["load", "metalhead"], ["to_bool"]]
    assert execute(inst, %User{}) == true
  end

  test "execute/2 returns to_bool error tuple" do
    inst2 = [["load", "is_superhero"], ["to_bool"]]

    assert execute(inst2, %User{}) ==
    {:error,
      %Predicator.ValueError{
        error: "Non valid load value to evaluate",
        instruction_pointer: 1,
        instructions: [["load", "is_superhero"], ["to_bool"]],
        stack: ["falsse"]
      }
    }
  end

  test "execute/1 returns not false" do
    inst = [["lit", false], ["not"]]
    assert execute(inst) == true
  end

  test "execute/1 returns integer equal integer" do
    inst = [["lit", 1], ["lit", 1], ["compare", "EQ"]]
    assert execute(inst) == true
  end

  test "integer in list" do
    inst = [["lit", 1], ["array", [1, 2]], ["compare", "IN"]]
    assert execute(inst) == true
  end

  test "string in list" do
    inst = [["lit", "UT"], ["array", ["UT", "NM"]], ["compare", "IN"]]
    assert execute(inst) == true
  end

  test "integer not in list" do
    inst = [["lit", 3], ["array", [1, 2]], ["compare", "NOTIN"]]
    assert execute(inst) == true
  end

  test "string not in list" do
    inst = [["lit", "NY"], ["array", ["UT", "NM"]], ["compare", "NOTIN"]]
    assert execute(inst) == true
  end

  test "execute/1 returns integer not equal to false" do
    inst = [["lit", 1], ["lit", nil], ["compare", "EQ"]]
    assert execute(inst) == false
  end

  # Write test to nil check comparison numbers

  # NOTE: fix test struct
  test "execute/2 returns variable equal integer" do
    inst = [["load", "age"], ["lit", 29], ["compare", "EQ"]]
    assert execute(inst, %User{}) == true
  end

  test "execute/2 returns variable greater_than integer" do
    inst = [["load", "age"], ["lit", 20], ["compare", "GT"]]
    assert execute(inst, %User{}) == true
  end

  test "execute/2 returns variable less_than integer" do
    inst = [["load", "age"], ["lit", 30], ["compare", "LT"]]
    assert execute(inst, %User{}) == true
  end

  test "execute/1 returns integer greater than integer" do
    inst = [["lit", 2], ["lit", 1], ["compare", "GT"]]
    assert execute(inst) == true
  end

  test "execute/1 returns true and true" do
    inst = [["lit", true], ["jfalse", 2], ["lit", true]]
    assert execute(inst) == true
  end

  test "execute/1 returns true or false" do
    inst = [["lit", true], ["jtrue", 2], ["lit", false]]
    assert execute(inst) == true
  end

  test "execute/1 returns false or integer equal integer" do
    inst = [["lit", false], ["jtrue", 4], ["lit", 1], ["lit", 1], ["compare", "EQ"]]
    assert execute(inst) == true
  end

  test "execute/1 inclusive evaluation of integer between integers" do
    inst = [["lit", 3], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]
    inst2 = [["lit", 1], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]
    inst3 = [["lit", 5], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]

    assert execute(inst) == true
    assert execute(inst2) == true
    assert execute(inst3) == true
  end

  test "execute/1 outputs error tuple when evaluating an invalid predicate" do
    inst = [["blabla", 2345], ["something", 342]]
    assert execute(inst) == {:error, %Predicator.InstructionError{
      error: "Non valid predicate instruction",
      instructions: [["blabla", 2345], ["something", 342]],
      predicate: "blabla",
      instruction_pointer: 0
    }}
  end

  test "execute/1 outputs error tuple with correct instruction pointer on invalid predicate" do
    inst = [["lit", 3], ["blabla", 2345]]
    assert execute(inst) == {:error, %Predicator.InstructionError{
      error: "Non valid predicate instruction",
      instructions: [["lit", 3], ["blabla", 2345]],
      predicate: "blabla",
      instruction_pointer: 1
    }}
  end
end

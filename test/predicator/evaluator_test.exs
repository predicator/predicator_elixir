defmodule TestUser, do: defstruct [name: "Joshua", string_age: "29", age: 29, metalhead: "true", is_superhero: "falsse"]

defmodule Predicator.EvaluatorTest do
  use ExUnit.Case
  import Predicator.Evaluator
  doctest Predicator.Evaluator

  describe "execute/1" do
    test "returns true" do
      inst = [["lit", true]]
      assert execute(inst) == true
    end

    test "returns false" do
      inst = [["lit", false]]
      assert execute(inst) == false
    end

    test "returns not true" do
      inst = [["lit", true], ["not"]]
      assert execute(inst) == false
    end

    test "returns not false" do
      inst = [["lit", false], ["not"]]
      assert execute(inst) == true
    end

    test "returns integer equal integer" do
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

    test "returns integer not equal to false" do
      inst = [["lit", 1], ["lit", nil], ["compare", "EQ"]]
      assert execute(inst) == false
    end

      test "returns integer greater than integer" do
      inst = [["lit", 2], ["lit", 1], ["compare", "GT"]]
      assert execute(inst) == true
    end

    test "returns true and true" do
      inst = [["lit", true], ["jfalse", 2], ["lit", true]]
      assert execute(inst) == true
    end

    test "returns true or false" do
      inst = [["lit", true], ["jtrue", 2], ["lit", false]]
      assert execute(inst) == true
    end

    test "returns false or integer equal integer" do
      inst = [["lit", false], ["jtrue", 4], ["lit", 1], ["lit", 1], ["compare", "EQ"]]
      assert execute(inst) == true
    end

    test "inclusive evaluation of integer between integers" do
      inst = [["lit", 3], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]
      inst2 = [["lit", 1], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]
      inst3 = [["lit", 5], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]

      assert execute(inst) == true
      assert execute(inst2) == true
      assert execute(inst3) == true
    end

    test "outputs error tuple when evaluating an invalid predicate" do
      inst = [["blabla", 2345], ["something", 342]]
      assert execute(inst) == {:error, %Predicator.InstructionError{
        error: "Non valid predicate instruction",
        instructions: [["blabla", 2345], ["something", 342]],
        predicate: "blabla",
        instruction_pointer: 0,
        opts: [map_type: :atom]
      }}
    end

    test "outputs error tuple with correct instruction pointer on invalid predicate" do
      inst = [["lit", 3], ["blabla", 2345]]
      assert execute(inst) == {:error, %Predicator.InstructionError{
        error: "Non valid predicate instruction",
        instructions: [["lit", 3], ["blabla", 2345]],
        predicate: "blabla",
        instruction_pointer: 1,
        opts: [map_type: :atom]
      }}
    end
  end


  describe "execute/2" do
    test "returns to_bool error tuple" do
      inst2 = [["load", "is_superhero"], ["to_bool"]]
      assert execute(inst2, %TestUser{}) ==
      {:error, %Predicator.ValueError{
          error: "Non valid load value to evaluate",
          instruction_pointer: 1,
          instructions: [["load", "is_superhero"], ["to_bool"]],
          stack: ["falsse"],
          opts: [map_type: :atom]
        }
      }
    end

    test "returns variable equal integer" do
      inst = [["load", "age"], ["lit", 29], ["compare", "EQ"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "returns variable greater_than integer" do
      inst = [["load", "age"], ["lit", 20], ["compare", "GT"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "returns variable less_than integer" do
      inst = [["load", "age"], ["lit", 30], ["compare", "LT"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "returns to_bool values" do
      inst = [["load", "metalhead"], ["to_bool"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "refutes binary being able to be coerced into to_bool value" do
      inst = [["load", "name"], ["to_bool"]]
      refute execute(inst, %TestUser{}) == true
    end

    test "returns to_int coercion from literal" do
      inst = [
        ["load", "string_age"],
        ["to_int"],
        ["lit", 29],
        ["compare", "EQ"]
      ]
      assert execute(inst, %TestUser{}) == true
    end

    test "returns to_int coercion from load_val" do
      inst = [
        ["load", "string_age"],
        ["to_int"],
        ["load", "age"],
        ["compare", "EQ"]
      ]
      assert execute(inst, %TestUser{}) == true
    end
  end


  describe "execute/3" do
    def str_map, do: %{"name" => "Joshua", "age" => 29, "metalhead" => "true", "is_superhero" => "falsse"}

    test "returns to_bool error tuple" do
      inst2 = [["load", "is_superhero"], ["to_bool"]]
      assert execute(inst2, str_map(), [map_type: :string]) ==
      {:error, %Predicator.ValueError{
          error: "Non valid load value to evaluate",
          instruction_pointer: 1,
          instructions: [["load", "is_superhero"], ["to_bool"]],
          stack: ["falsse"],
          opts: [map_type: :string]
        }
      }
    end

    test "execute/3 returns variable equal to integer in string_keyed_map" do
      inst = [["load", "age"], ["lit", 29], ["compare", "EQ"]]
      assert execute(inst, str_map(), [map_type: :string]) == true
    end

    test "execute/3 returns variable greater_than integer" do
      inst = [["load", "age"], ["lit", 20], ["compare", "GT"]]
      assert execute(inst, str_map(), [map_type: :string]) == true
    end

    test "execute/3 returns variable less_than integer" do
      inst = [["load", "age"], ["lit", 30], ["compare", "LT"]]
      assert execute(inst, str_map(), [map_type: :string]) == true
    end
  end

end

defmodule Predicator.EvaluatorOperation.ToBoolTest do
  use ExUnit.Case
  import Predicator.Evaluator

  defmodule TestUser do
    defstruct [
      name: "Joshua",
      metalhead: "true",
      is_superhero: "falsse",
      true_val: true,
      false_val: false
    ]
  end

  describe "[\"TOBOOL\"] operation" do
    test "true load val" do
      inst = [["load", "true_val"], ["to_bool"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "false load val" do
      inst = [["load", "metalhead"], ["to_bool"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "random load val" do
      inst = [["load", "metalhead"], ["to_bool"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "refutes binary being coerced into TOBOOL value" do
      inst = [["load", "name"], ["to_bool"]]
      refute execute(inst, %TestUser{}) == true
    end

    test "returns TOBOOL error tuple" do
      inst = [["load", "is_superhero"], ["to_bool"]]
      assert execute(inst, %TestUser{}) ==
        {:error, %Predicator.ValueError{
            error: "Non valid load value to evaluate",
            instruction_pointer: 1,
            instructions: [["load", "is_superhero"], ["to_bool"]],
            stack: ["falsse"],
            opts: [map_type: :atom, nil_values: ["", nil]]
          }
        }
    end
  end
end

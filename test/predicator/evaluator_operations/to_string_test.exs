defmodule Predicator.EvaluatorOperation.ToStringTest do
  use ExUnit.Case
  import Predicator.Evaluator

  @moduletag :parsed

  defmodule TestUser do
    defstruct [
      age: 29,
      string_age: "29",
      nil_val: nil,
      true_val: true,
      false_val: false
    ]
  end

  describe "[\"TOSTRING\"] operation" do
    test "integer coercion from lit & load val" do
      inst = [
        ["lit", 29], ["to_str"],
        ["lit", "29"], ["comparator", "EQ"]
      ]

      inst2 = [
        ["load", "age"], ["to_str"],
        ["lit", "29"], ["comparator", "EQ"]
      ]
      assert execute(inst) == true
      assert execute(inst2, %TestUser{}) == true
    end

    test "nil coercion from lit & load val" do
      inst = [
        ["lit", nil], ["to_str"],
        ["lit", "nil"], ["comparator", "EQ"]
      ]

      inst2 = [
        ["load", "nil_val"], ["to_str"],
        ["lit", "nil"], ["comparator", "EQ"]
      ]

      assert execute(inst) == true
      assert execute(inst2, %TestUser{}) == true
    end

    test "true coercion from lit & load val" do
      true_inst = [
        ["lit", true], ["to_str"],
        ["lit", "true"], ["comparator", "EQ"]
      ]
      true_inst2 = [
        ["load", "true_val"], ["to_str"],
        ["lit", "true"], ["comparator", "EQ"]
      ]
      assert execute(true_inst) == true
      assert execute(true_inst2, %TestUser{}) == true
    end

    test "false coercion from lit & load val" do
      true_inst = [
        ["lit", false], ["to_str"],
        ["lit", "false"], ["comparator", "EQ"]
      ]
      true_inst2 = [
        ["load", "false_val"], ["to_str"],
        ["lit", "false"], ["comparator", "EQ"]
      ]
      assert execute(true_inst) == true
      assert execute(true_inst2, %TestUser{}) == true
    end
  end
end

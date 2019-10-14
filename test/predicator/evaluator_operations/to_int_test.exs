defmodule Predicator.EvaluatorOperation.ToIntTest do
  use ExUnit.Case
  import Predicator.Evaluator

  @moduletag :parsed

  defmodule TestUser, do: defstruct [string_age: "29", age: 29]

  describe "[\"TOINT\"] operation" do
    test "string_int coercion from lit val" do
      inst = [
        ["lit", "29"],
        ["to_int"],
        ["load", "age"],
        ["comparator", "EQ"]
      ]
      assert execute(inst, %TestUser{}) == true
    end

    test "string_int coercion from load" do
      inst = [
        ["load", "string_age"],
        ["to_int"],
        ["lit", 29],
        ["comparator", "EQ"]
      ]
      assert execute(inst, %TestUser{}) == true
    end

  end
end

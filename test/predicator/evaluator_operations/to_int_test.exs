
defmodule Predicator.EvaluatorOperation.ToIntTest do
  use ExUnit.Case
  import Predicator.Evaluator

  defmodule TestUser, do: defstruct [string_age: "29", age: 29]

  describe "[\"TOINT\"] operation" do
    test "string_int coercion from lit val" do
      inst = [
        ["lit", "29"],
        ["to_int"],
        ["load", "age"],
        ["compare", "EQ"]
      ]
      assert execute(inst, %TestUser{}) == true
    end

    test "string_int coercion from load" do
      inst = [
        ["load", "string_age"],
        ["to_int"],
        ["lit", 29],
        ["compare", "EQ"]
      ]
      assert execute(inst, %TestUser{}) == true
    end

  end
end

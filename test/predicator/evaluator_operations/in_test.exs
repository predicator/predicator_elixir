defmodule Predicator.EvaluatorOperation.InTest do
  use ExUnit.Case
  import Predicator.Evaluator

  @moduletag :parsed

  describe "[\"IN\"] operation" do
    test "integer IN list" do
      inst = [["lit", 1], ["array", [1, 2]], ["comparator", "IN"]]

      assert execute(inst) == true
    end

    test "string IN list" do
      inst = [["lit", "UT"], ["array", ["UT", "NM"]], ["comparator", "IN"]]
      assert execute(inst) == true
    end
  end
end

defmodule Predicator.EvaluatorOperation.BetweenTest do
  use ExUnit.Case
  import Predicator.Evaluator

  describe "[\"BETWEEN\"] operation" do
    test "inclusive evaluation of integer BETWEEN integers" do
      inst = [["lit", 3], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]
      inst2 = [["lit", 1], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]
      inst3 = [["lit", 5], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]

      assert execute(inst) == true
      assert execute(inst2) == true
      assert execute(inst3) == true
    end
  end
end

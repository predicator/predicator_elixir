defmodule Predicator.EvaluatorOperation.BetweenTest do
  use ExUnit.Case
  import Predicator.Evaluator

  defmodule TstStruct, do: defstruct [created_at: "2012-12-12"]

  describe "[\"BETWEEN\"] operation" do
    @tag :current
    test "inclusive evaluation of integer BETWEEN integers" do
      inst  = [["lit", 3], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]
      inst2 = [["lit", 1], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]
      inst3 = [["lit", 5], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]

      assert execute(inst) == true
      assert execute(inst2) == true
      assert execute(inst3) == true
    end

    test "date eval true between dates" do
      inst = [
        ["lit", "2012-12-12"],
        ["to_date"],
        ["lit", 1],
        ["to_date"],
        ["lit", 5000000000],
        ["to_date"],
        ["compare", "BETWEEN"]
      ]
      assert execute(inst) == true
    end

    test "date eval with load is true between dates" do
      inst = [
        ["load", "created_at"],
        ["to_date"],
        ["lit", 259200],
        ["to_date"],
        ["lit", 5000000000],
        ["to_date"],
        ["compare", "BETWEEN"]
      ]
      assert execute(inst, %TstStruct{}) == true
    end
  end
end

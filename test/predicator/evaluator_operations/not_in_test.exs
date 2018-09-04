
defmodule Predicator.EvaluatorOperation.NotInTest do
  use ExUnit.Case
  import Predicator.Evaluator

  alias __MODULE__
  defmodule TestUser, do: defstruct [age: 30, state: "WA"]

  describe "[\"NOTIN\"] operation" do
    test "lit integer NOTIN list" do
      inst = [["lit", 3], ["array", [1, 2]], ["compare", "NOTIN"]]
      assert execute(inst) == true
    end

    test "lit string NOTIN list" do
      inst = [["lit", "NY"], ["array", ["UT", "NM"]], ["compare", "NOTIN"]]
      assert execute(inst) == true
    end

    test "load integer NOTIN list" do
      inst = [["load", "age"], ["array", [1, 2]], ["compare", "NOTIN"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "load string NOTIN list" do
      inst = [["load", "state"], ["array", ["UT", "NM"]], ["compare", "NOTIN"]]
      assert execute(inst, %TestUser{}) == true
    end
  end
end

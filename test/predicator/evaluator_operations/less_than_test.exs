defmodule Predicator.EvaluatorOperation.LessThanTest do
  use ExUnit.Case
  import Predicator.Evaluator

  defmodule TestUser, do: defstruct [string_age: "29", age: 29]

  describe "[\"LT\"] operation" do
    test "load val LT integer" do
      inst = [["load", "age"], ["lit", 30], ["compare", "LT"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "load val from string-keyed map LT integer" do
      str_map = %{"name" => "Joshua", "age" => 29, "metalhead" => "true", "is_superhero" => "falsse"}
      inst = [["load", "age"], ["lit", 30], ["compare", "LT"]]

      assert execute(inst, str_map, [map_type: :string]) == true
    end
  end

end

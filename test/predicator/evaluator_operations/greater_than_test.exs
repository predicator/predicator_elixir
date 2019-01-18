defmodule Predicator.EvaluatorOperation.GreaterThanTest do
  use ExUnit.Case
  import Predicator.Evaluator

  @moduletag :parsed

  defmodule TestUser, do: defstruct [string_age: "29", age: 29]

  describe "[\"GT\"] operation" do
    test "lit GT integer" do
      inst = [["lit", 2], ["lit", 1], ["comparator", "GT"]]
      assert execute(inst) == true
    end

    test "load val GT integer" do
      inst = [["load", "age"], ["lit", 20], ["comparator", "GT"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "load val from string-keyed map GT integer" do
      map = %{"name" => "Joshua", "age" => 29, "metalhead" => "true", "is_superhero" => "falsse"}
      inst = [["load", "age"], ["lit", 20], ["comparator", "GT"]]

      assert execute(inst, map, [map_type: :string]) == true
    end
  end
end

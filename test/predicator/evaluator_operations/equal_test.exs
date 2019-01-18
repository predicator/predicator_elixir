defmodule Predicator.EvaluatorOperation.EqualTest do
  use ExUnit.Case
  import Predicator.Evaluator

  @moduletag :parsed

  defmodule TestUser, do: defstruct [age: 29]

  describe "[\"EQ\"] operation" do

    test "lit integer EQ integer" do
      inst = [["lit", 1], ["lit", 1], ["comparator", "EQ"]]
      assert execute(inst) == true
    end

    test "lit integer not EQ to false" do
      inst = [["lit", 1], ["lit", nil], ["comparator", "EQ"]]
      assert execute(inst) == false
    end

    test "load val EQ integer" do
      inst = [["load", "age"], ["lit", 29], ["comparator", "EQ"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "execute/3 variable EQ to integer in string_keyed_map" do
      map = %{"name" => "Joshua", "age" => 29, "metalhead" => "true", "is_superhero" => "falsse"}
      inst = [["load", "age"], ["lit", 29], ["comparator", "EQ"]]

      assert execute(inst, map, [map_type: :string]) == true
    end
  end
end

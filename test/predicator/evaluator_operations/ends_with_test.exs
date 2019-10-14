defmodule Predicator.EvaluatorOperation.EndsWithTest do
  use ExUnit.Case
  import Predicator.Evaluator

  @moduletag :parsed

  defmodule TestUser, do: defstruct [website: "sanfransiscoisoldnews.com"]

  describe "[\"ENDSWITH\"] Comparison operator" do
    test "execute/1 lit val ends with charset" do
      inst = [["lit", "13 dollars"], ["lit", "dollars"], ["comparator", "ENDSWITH"]]
      assert execute(inst) == true
    end

    test "execute/2 load val ends with charset" do
      inst = [["load", "website"], ["lit", ".com"], ["comparator", "ENDSWITH"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "execute/3 load val ends with charset" do
      map = %{"website" => "sanfransiscoisoldnews.com"}
      inst = [["load", "website"], ["lit", ".com"], ["comparator", "ENDSWITH"]]
      assert execute(inst, map, [map_type: :string]) == true
    end
  end

end

defmodule Predicator.EvaluatorOperation.StartsWithTest do
  use ExUnit.Case
  import Predicator.Evaluator

  @moduletag :parsed

  defmodule TestUser, do: defstruct(website: "http://sanfransiscoisoldnews.com")

  describe "[\"STARTSWITH\"] Comparison operator" do
    test "execute/1 lit val ends with charset" do
      inst = [["lit", "Ms. Tulip"], ["lit", "Ms."], ["compare", "STARTSWITH"]]
      assert execute(inst) == true
    end

    test "execute/2 load val ends with charset" do
      inst = [["load", "website"], ["lit", "http://"], ["compare", "STARTSWITH"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "execute/3 load val ends with charset" do
      map = %{"date" => "monday the 31st"}
      inst = [["load", "date"], ["lit", "monday"], ["compare", "STARTSWITH"]]
      assert execute(inst, map, map_type: :string) == true
    end
  end
end

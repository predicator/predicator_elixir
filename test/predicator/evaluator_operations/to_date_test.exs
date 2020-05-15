defmodule Predicator.EvaluatorOperation.ToDateTest do
  use ExUnit.Case
  import Predicator.Evaluator

  @moduletag :parsed

  defmodule TestUser,
    do: defstruct(created_at: "2012-01-31 18:14:13.0", string_age: "29", age: 29)

  describe "Predicator.Evaluator.Date module import functions" do
  end

  # "2017-09-10"
  describe "[\"TO_DATE\"] operation" do
    test "lit val convert" do
      inst = [
        ["lit", "2017-09-10"],
        ["to_date"],
        ["lit", "2017-09-10"],
        ["to_date"],
        ["compare", "EQ"]
      ]

      assert execute(inst) == true
    end
  end

  describe "[\"DATE_AGO\"] operation" do
    test "less then eval false" do
      inst = [
        ["load", "created_at"],
        ["to_date"],
        ["lit", 259_200],
        ["date_ago"],
        ["lit", 432_000],
        ["date_ago"],
        ["compare", "BETWEEN"]
      ]

      assert execute(inst, %TestUser{}) == false
    end
  end

  describe "[\"DATE_FROM_NOW\"] operation" do
    test "less then eval true" do
      inst = [
        ["load", "created_at"],
        ["to_date"],
        ["lit", 259_200],
        ["date_from_now"],
        ["lit", 432_000],
        ["date_from_now"],
        ["compare", "BETWEEN"]
      ]

      assert execute(inst, %TestUser{}) == false
    end
  end
end

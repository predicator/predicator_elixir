defmodule Predicator.EvaluatorOperation.ToDateTest do
  use ExUnit.Case
  import Predicator.Evaluator
  import Predicator.Evaluator.Date, only: [_execute: 2, _convert_date: 1]
  alias __MODULE__

  defmodule TestUser, do: defstruct [string_age: "29", age: 29]

  describe "Predicator.Evaluator.Date module import functions" do

  end

  # "2017-09-10"
  describe "[\"TO_DATE\"] operation" do
    test "lit val convert" do
      inst = [["lit", "2017-09-10"], ["to_date"], ["lit", "2017-09-10"], ["to_date"], ["compare", "EQ"]]
      assert execute(inst) == true
    end
  end

end

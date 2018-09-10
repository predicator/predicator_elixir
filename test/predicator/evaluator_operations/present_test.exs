
defmodule Predicator.EvaluatorOperation.PresentTest do
  use ExUnit.Case
  import Predicator.Evaluator

  defmodule TestUser do
    defstruct [
      age: 29,
      metalhead: "true",
      nil_val: nil,
      blank_with_nil_options: "dog"
    ]
  end

  describe "[\"PRESENT\"] operation" do
    test "true when existing val" do
      inst1 = [["lit", 12], ["present"]]
      inst2 = [["lit", " "], ["present"]]
      inst3 = [["lit", "hello"], ["present"]]
      inst4 = [["lit", %{key: "some_val"}], ["present"]]
      assert execute(inst1) == true
      assert execute(inst2) == true
      assert execute(inst3) == true
      assert execute(inst4) == true
    end

    test "false when blank val" do
      inst1 = [["lit", ""], ["present"]]
      inst2 = [["lit", nil], ["present"]]
      assert execute(inst1) == false
      assert execute(inst2) == false
    end

    test "true when loaded existing val" do
      inst1 = [["load", "age"], ["present"]]
      inst2 = [["load", "metalhead"], ["present"]]

      assert execute(inst1, %TestUser{}) == true
      assert execute(inst2, %TestUser{}) == true
    end

    test "false when loaded blank val" do
      inst1 = [["load", "nil_val"], ["present"]]
      assert execute(inst1, %TestUser{}) == false
    end

    test "tests PRESENT with load & extra nil opts" do
      custom_opts = [map_type: :atom, nil_values: ["", nil, "dog"]]

      present1 = [["load", "blank_with_nil_options"], ["present"]]
      present2 = [["load", "blank_with_nil_options"], ["present"]]
      assert execute(present1, %TestUser{}, custom_opts) == false
      assert execute(present2, %TestUser{}, custom_opts) == false
    end
  end
end

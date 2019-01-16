defmodule Predicator.EvaluatorOperation.BlankTest do
  use ExUnit.Case
  import Predicator.Evaluator

  defmodule TestUser do
    defstruct [
      name: "Joshua",
      string_age: "29",
      age: 29,
      metalhead: "true",
      is_superhero: "falsse",
      nil_val: nil,
      blank_with_nil_options: "dog",
      true_val: true,
      false_val: false
    ]
  end

  describe "[\"BLANK\"] operation" do
    test "false when existing lit val" do
      inst1 = [["lit", 12], ["blank"]]
      inst2 = [["lit", " "], ["blank"]]
      inst3 = [["lit", "hello"], ["blank"]]
      inst4 = [["lit", %{key: "some_val"}], ["blank"]]
      assert execute(inst1) == false
      assert execute(inst2) == false
      assert execute(inst3) == false
      assert execute(inst4) == false
    end

    test "true when blank val" do
      inst1 = [["lit", ""], ["blank"]]
      inst2 = [["lit", nil], ["blank"]]
      assert execute(inst1) == true
      assert execute(inst2) == true
    end

    test "false when loaded existing val" do
      inst1 = [["load", "age"], ["blank"]]
      inst2 = [["load", "metalhead"], ["blank"]]

      assert execute(inst1, %TestUser{}) == false
      assert execute(inst2, %TestUser{}) == false
    end

    test "true when loaded blank val" do
      inst = [["load", "nil_val"], ["blank"]]
      assert execute(inst, %TestUser{}) == true
    end

    test "BLANK with load & extra nil opts" do
      custom_opts = [map_type: :atom, nil_values: ["", nil, "dog"]]
      blank1 = [["load", "blank_with_nil_options"], ["blank"]]
      blank2 = [["load", "blank_with_nil_options"], ["blank"]]
      assert execute(blank1, %TestUser{}, custom_opts) == true
      assert execute(blank2, %TestUser{}, custom_opts) == true
    end

    test "not BLANK with changed default opts" do
      custom_opts = [map_type: :atom, nil_values: ["IAmTheNewNil"]]
      blank1 = [["load", "nil_val"], ["blank"]]
      blank2 = [["load", "nil_val"], ["blank"]]
      assert execute(blank1, %TestUser{}, custom_opts) == false
      assert execute(blank2, %TestUser{}, custom_opts) == false
    end
  end

end

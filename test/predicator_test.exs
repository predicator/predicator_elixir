defmodule User do
  defstruct [name: "Joshua", age: 29]
end

defmodule PredicatorTest do
  use ExUnit.Case
  import Evaluator


  test "execute/1 returns true" do
    inst = [["lit", true]]
    assert execute(inst) == true
  end

  # @tag :skip
  test "execute/1 returns false" do
    inst = [["lit", false]]
    assert execute(inst) == false
  end

  # @tag :skip
  test "execute/1 returns not true" do
    inst = [["lit", true], ["not"]]
    assert execute(inst) == false
  end

  test "execute/1 returns not false" do
    inst = [["lit", false], ["not"]]
    assert execute(inst) == true
  end

  # @tag :skip
  test "execute/1 returns integer equal integer" do
    inst = [["lit", 1], ["lit", 1], ["compare", "EQ"]]
    assert execute(inst) == true
  end

  test "execute/1 returns integer not equal to false" do
    inst = [["lit", 1], ["lit", nil], ["compare", "EQ"]]
    assert execute(inst) == false
  end

  # Write test to nil check comparison numbers

  # @tag :skip
  # NOTE: fix test struct
  test "execute/2 returns variable equal integer" do
    inst = [["load", "age"], ["lit", 29], ["compare", "EQ"]]
    assert execute(inst, %User{}) == true
  end

  # @tag :skip
  test "execute/1 returns integer greater than integer" do
    inst = [["lit", 2], ["lit", 1], ["compare", "GT"]]
    assert execute(inst) == true
  end

  # @tag :skip
  test "execute/1 returns true and true" do
    inst = [["lit", true], ["jfalse", 2], ["lit", true]]
    assert execute(inst) == true
  end

  # @tag :skip
  test "execute/1 returns true or false" do
    inst = [["lit", true], ["jtrue", 2], ["lit", false]]
    assert execute(inst) == true
  end

  # @tag :skip
  test "execute/1 returns false or integer equal integer" do
    inst = [["lit", false], ["jtrue", 4], ["lit", 1], ["lit", 1], ["compare", "EQ"]]
    assert execute(inst) == true
  end

  # @tag :skip
  test "execute/1 inclusive evaluation of integer between integers" do
    inst = [["lit", 3], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]
    inst2 = [["lit", 1], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]
    inst3 = [["lit", 5], ["lit", 1], ["lit", 5], ["compare", "BETWEEN"]]

    assert execute(inst) == true
    assert execute(inst2) == true
    assert execute(inst3) == true
  end

end

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
  test "execute/1 returns not" do
    inst = [["lit", true], ["not"]]
    assert execute(inst) == false
  end

  # @tag :skip
  test "execute/1 returns integer equal integer" do
    inst = [["lit", 1], ["lit", 1], ["compare", "EQ"]]
    assert execute(inst) == true
  end

  # Write test to nil check comparison numbers

  @tag :skip
  test "execute/1 returns variable equal integer" do
    inst = [["load", "age"], ["lit", 21], ["compare", "EQ"]]

  end

  @tag :skip
  test "execute/1 returns integer greater than integer" do
    inst = [["lit", 2], ["lit", 1], ["compare", "GT"]]
    assert execute(inst) == []
  end

  @tag :skip
  test "execute/1 returns true and true" do
    inst = [["lit", true], ["jfalse", 2], ["lit", true]]
  end

  @tag :skip
  test "execute/1 returns true or false" do
    inst = [["lit", true], ["jtrue", 2], ["lit", false]]
  end

  @tag :skip
  test "execute/1 returns false or integer equal integer" do
    inst = [["lit", false], ["jtrue", 4], ["lit", 1], ["lit", 1], ["compare", "EQ"]]
  end

end

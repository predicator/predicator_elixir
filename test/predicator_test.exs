defmodule PredicatorTest do
  use ExUnit.Case
  import Predicator
  doctest Predicator

  @moduletag :parsing

  describe "BETWEEN" do
    test "compiles" do
      assert {:ok, [[:load, :age], [:lit, 5], [:lit, 10], [:comparator, :BETWEEN]]} =
        Predicator.compile("age between 5 and 10", :atom_key_inst)
      assert {:ok, [["load", "age"], ["lit", 5], ["lit", 10], ["comparator", "BETWEEN"]]} =
        Predicator.compile("age between 5 and 10")
    end
  end

  describe "BLANK" do
    test "not currently supported" do
      assert {:error, _} = Predicator.compile("name blank")
    end
  end

  describe "ENDSWITH" do
    test "compiles" do
      assert {:ok, [[:load, :foobar], [:lit, "bar"], [:comparator, :ENDSWITH] ]} =
        Predicator.compile("foobar ends with 'bar'", :atom_key_inst)
      assert {:ok, [[:lit, "foobar"], [:lit, "bar"], [:comparator, :ENDSWITH] ]} =
        Predicator.compile("'foobar' ends with 'bar'", :atom_key_inst)
      assert {:ok, [["lit", "foobar"], ["lit", "bar"], ["comparator", "ENDSWITH"] ]} =
        Predicator.compile("'foobar' ends with 'bar'")
      assert {:ok, [["load", "foobar"], ["lit", "bar"], ["comparator", "ENDSWITH"] ]} =
        Predicator.compile("foobar ends with 'bar'")
    end

    test "evaluates to true" do
      assert Predicator.matches?("foobar ends with 'bar'", foobar: "foobar") == true
    end
  end

  describe "EQ" do
    test "compiles" do
      assert {:ok, _} = Predicator.compile("foo = 1")
    end

    test "returns true if the equality is true" do
      assert Predicator.matches?("foo = 1", foo: 1) == true
    end

    test "returns false if the equality is untrue" do
      assert Predicator.matches?("foo = 1", foo: 2) == false
    end
  end

  describe "GT" do
    test "compiles" do
      assert {:ok, _} = Predicator.compile("foo > 1")
    end

    test "returns true if the inequality is true" do
      assert Predicator.matches?("foo > 1", foo: 2) == true
    end

    test "returns false if the inequality is untrue" do
      assert Predicator.matches?("foo > 1", foo: 1) == false
    end
  end

  describe "IN" do
    test "compiles" do
      assert {:ok, [[:load, :foo], [:array, [1, 5, 7, 20]],[:comparator, :IN]]} =
        Predicator.compile("foo in [1, 5, 7, 20]", :atom_key_inst)
      assert {:ok, [["load", "foo"], ["array", [1, 5]], ["comparator", "IN"]]} =
        Predicator.compile("foo in [1, 5]", :string_key_inst)
    end

    test "evaluates to true" do
      assert Predicator.matches?("foo in [0, 1, 2, 3]", foo: 0) == true
    end
  end

  describe "JUMP" do
  end

  describe "LT" do
    test "compiles" do
      assert {:ok, _} = Predicator.compile("foo < 1")
    end

    test "returns true if the inequality is true" do
      assert Predicator.matches?("foo < 1", foo: 0) == true
    end

    test "returns false if the inequality is untrue" do
      assert Predicator.matches?("foo < 1", foo: 1) == false
    end
  end

  describe "NOTIN" do
    test "compiles" do
      assert {:ok, [[:load, :foo], [:array, [1, 2, 3]], [:comparator, :NOTIN]]} =
        Predicator.compile("foo not in [1, 2, 3]", :atom_key_inst)
      assert {:ok, [["load", "foo"], ["array", [1, 2, 3]], ["comparator", "NOTIN"]]} =
        Predicator.compile("foo not in [1, 2, 3]")
    end

    test "evaluates to true" do
      assert Predicator.matches?("foo not in [1, 2, 3]", foo: 0) == true
    end
  end

  describe "PRESENT" do
    test "not currently supported" do
      assert {:error, _} = Predicator.compile("name present")
    end
  end

  describe "STARTSWITH" do
    test "compiles" do
      assert {:ok, [[:load, :name], [:lit, "stuff"], [:comparator, :STARTSWITH]]} =
        Predicator.compile("name starts with 'stuff'", :atom_key_inst)
      assert {:ok, [[:lit, "name"], [:lit, "stuff"], [:comparator, :STARTSWITH]]} =
        Predicator.compile("'name' starts with 'stuff'", :atom_key_inst)

      assert {:ok, [["load", "name"], ["lit", "stuff"], ["comparator", "STARTSWITH"]]} =
        Predicator.compile("name starts with 'stuff'")
      assert {:ok, [["lit", "name"], ["lit", "stuff"], ["comparator", "STARTSWITH"]]} =
        Predicator.compile("'name' starts with 'stuff'")
    end
  end

  describe "OR" do
    test "not currently supported" do
      assert {:error, _} = Predicator.compile("true or false")
    end
  end
end

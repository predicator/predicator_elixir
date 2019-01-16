defmodule PredicatorTest do
  use ExUnit.Case
  import Predicator
  doctest Predicator

  describe "BETWEEN" do
    test "not currently supported" do
      assert {:error, _} = Predicator.compile("age between 5 and 10")
    end
  end

  describe "BLANK" do
    test "not currently supported" do
      assert {:error, _} = Predicator.compile("name blank")
    end
  end

  describe "ENDSWITH" do
    test "not currently supported" do
      assert {:error, _} = Predicator.compile("name ends with 'stuff'")
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
    test "not currently supported" do
      assert {:error, _} = Predicator.compile("foo in [1, 2, 3]")
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
    test "not currently supported" do
      assert {:error, _} = Predicator.compile("foo not in [1, 2, 3]")
    end
  end

  describe "PRESENT" do
    test "not currently supported" do
      assert {:error, _} = Predicator.compile("name present")
    end
  end

  describe "STARTSWITH" do
    test "not currently supported" do
      assert {:error, _} = Predicator.compile("name starts with 'stuff'")
    end
  end
end

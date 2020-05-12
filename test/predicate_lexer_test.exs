defmodule Predicator.PredicateLexerTest do
  use ExUnit.Case

  @lexer :predicate_lexer

  describe "string" do
    test "lexes string wrapped in single quotes" do
      example = "'foo'" |> to_charlist()
      assert {:ok, [{:string, "foo", 1}], 1} == @lexer.string(example)
    end

    test "lexes string wrapped in double quotes" do
      example = "\"foo\"" |> to_charlist()
      assert {:ok, [{:string, "foo", 1}], 1} == @lexer.string(example)
    end
  end
end

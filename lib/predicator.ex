defmodule Predicator do
  @moduledoc """
  Documentation for Predicator.
  """

  @lexer :predicator_lexer
  @parser :predicator_parser

  @doc """
  leex_string/1 takes string or charlist and returns a lexed tuple for parsing.

    iex> leex_string('10 > 5')
    {:ok, [{:lit, 1, 10}, {:comparator, 1, :GT}, {:lit, 1, 5}], 1}

    iex> leex_string("apple > 5532")
    {:ok, [{:load, 1, :apple}, {:comparator, 1, :GT}, {:lit, 1, 5532}], 1}
  """
  @spec leex_string(String.t) :: {:ok|:error, list|tuple, non_neg_integer()}
  def leex_string(str) when is_binary(str), do: @lexer.string(to_charlist(str))
  def leex_string(str) when is_list(str), do: @lexer.string(str)


  @doc """
  parse_lexed/1 takes a lexed tuple or just the token from the tuple and returns a predicate.

    iex> parse_lexed({:ok, [{:load, 1, :apple}, {:comparator, 1, :GT}, {:lit, 1, 5532}], 1})
    {:ok, [[:load, :apple], [:lit, 5532], [:comparator, :GT]]}

    iex> parse_lexed([{:load, 1, :apple}, {:comparator, 1, :GT}, {:lit, 1, 5532}])
    {:ok, [[:load, :apple], [:lit, 5532], [:comparator, :GT]]}
  """
  @spec parse_lexed({:ok, list, any}) :: {:ok|:error, list|tuple}
  def parse_lexed({_, token, _}), do: @parser.parse(token)
  def parse_lexed(token) when is_list(token), do: @parser.parse(token)


  @doc """
  leex_and_parse/1 takes a string or charlist and does all lexing and parsing then
  returns the predicate.

    iex> leex_and_parse("13 > 12")
    [[:lit, 13], [:lit, 12], [:comparator, :GT]]

    iex> leex_and_parse('532 == 532')
    [[:lit, 532], [:lit, 532], [:comparator, :EQ]]
  """
  @spec leex_and_parse(String.t) :: list|{:error, any()}
  def leex_and_parse(str) do
    with {:ok, tokens, _} <- leex_string(str),
         {:ok, predicate} <- parse_lexed(tokens),
        do: predicate
  end


end

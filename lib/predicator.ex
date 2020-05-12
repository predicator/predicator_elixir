defmodule Predicator do
  @moduledoc """
  Documentation for Predicator.

  Lexer and Parser currently compatible with 1.1.0 predicate syntax
  """
  alias Predicator.Evaluator

  @lexer :predicate_lexer
  @atom_parser :atom_instruction_parser
  @string_parser :string_instruction_parser

  @type token_key_t ::
          :atom_key_inst
          | :string_key_inst

  @type predicate :: String.t() | charlist

  @doc """
  leex_string/1 takes string or charlist and returns a lexed tuple for parsing.

  iex> leex_string('10 > 5')
  {:ok, [{:lit, 1, 10}, {:comparator, 1, :GT}, {:lit, 1, 5}], 1}

  iex> leex_string("apple > 5532")
  {:ok, [{:load, 1, :apple}, {:comparator, 1, :GT}, {:lit, 1, 5532}], 1}
  """
  @spec leex_string(predicate) :: {:ok | :error, list | tuple, non_neg_integer()}
  def leex_string(str) when is_binary(str), do: str |> to_charlist |> leex_string
  def leex_string(str) when is_list(str), do: @lexer.string(str)

  @doc """
  parse_lexed/1 takes a leexed token(list or tup) and returns a predicate. It also
  can take optional atom for type of token keys to return. options are `:string_ey_inst` & `:atom_key_inst`

  iex> parse_lexed({:ok, [{:load, 1, :apple}, {:comparator, 1, :GT}, {:lit, 1, 5532}], 1})
  {:ok, [["load", "apple"], ["lit", 5532], ["comparator", "GT"]]}

  iex> parse_lexed({:ok, [{:load, 1, :apple}, {:comparator, 1, :GT}, {:lit, 1, 5532}], 1}, :string_key_inst)
  {:ok, [["load", "apple"], ["lit", 5532], ["comparator", "GT"]]}

  iex> parse_lexed([{:load, 1, :apple}, {:comparator, 1, :GT}, {:lit, 1, 5532}], :atom_key_inst)
  {:ok, [[:load, :apple], [:lit, 5532], [:comparator, :GT]]}
  """
  @spec parse_lexed(list, token_key_t) :: {:ok | :error, list | tuple}
  def parse_lexed(token, opt \\ :string_key_inst)
  def parse_lexed(token, :string_key_inst) when is_list(token), do: @string_parser.parse(token)
  def parse_lexed({_, token, _}, :string_key_inst), do: @string_parser.parse(token)

  def parse_lexed(token, :atom_key_inst) when is_list(token), do: @atom_parser.parse(token)
  def parse_lexed({_, token, _}, :atom_key_inst), do: @atom_parser.parse(token)

  @doc """
  leex_and_parse/1 takes a string or charlist and does all lexing and parsing then
  returns the predicate.

  iex> leex_and_parse("13 > 12")
  [["lit", 13], ["lit", 12], ["comparator", "GT"]]

  iex> leex_and_parse('532 == 532', :atom_key_inst)
  [[:lit, 532], [:lit, 532], [:comparator, :EQ]]
  """
  @spec leex_and_parse(String.t()) :: list | {:error, any(), non_neg_integer}
  def leex_and_parse(str, token_type \\ :string_key_inst) do
    with {:ok, tokens, _} <- leex_string(str),
         {:ok, predicate} <- parse_lexed(tokens, token_type) do
      predicate
    end
  end

  @doc "eval/3 takes a predicate set, a context struct and options"
  def eval(inst, context \\ %{}, opts \\ [map_type: :string, nil_values: ["", nil]])
  def eval(inst, context, opts), do: Evaluator.execute(inst, context, opts)

  def compile(predicate, token_type \\ :string_key_inst) do
    with {:ok, tokens, _} <- leex_string(predicate),
         {:ok, predicate} <- parse_lexed(tokens, token_type) do
      {:ok, predicate}
    else
      {:error, _} = err -> err
      {:error, left, right} -> {:error, {left, right}}
    end
  end

  def matches?(predicate), do: matches?(predicate, [])

  def matches?(predicate, context) when is_list(context) do
    matches?(predicate, Map.new(context))
  end

  def matches?(predicate, context) when is_binary(predicate) or is_list(predicate) do
    with {:ok, predicate} <- compile(predicate) do
      eval(predicate, context)
    end
  end
end

defmodule Predicator.DateConversionError do
  @moduledoc """
  Error struct returned by Date Conversion Error.

    iex> %Predicator.DateConversionError{}
    %Predicator.DateConversionError{error: "Date was not parsable", date: nil}
  """
  @type t :: %__MODULE__{
    error: String.t(),
    date: NaiveDateTime.t
  }

  defstruct [
    error: "Date was not parsable",
    date: nil
  ]
end

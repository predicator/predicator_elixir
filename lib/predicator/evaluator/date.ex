defmodule Predicator.Evaluator.Date do
  @moduledoc false
  alias Predicator.{
    Machine,
    DateConversionError
  }


  def _execute(["to_date"|_], m=%Machine{stack: [date|rest_of_stack]}) do
    mach = %Machine{m| stack: [_convert_date(date)|rest_of_stack], ip: m.ip + 1 }

    mach
    |> Predicator.Evaluator._get_instruction()
    |> Predicator.Evaluator._execute(mach)
  end

  # # [["load", "created_at"], ["to_date"], ["lit", 259200], ["date_ago"], ["compare", "LT"]]
  # defp _execute(["date_ago"|_], machine=%Machine{stack: [date_in_seconds|rest_of_stack]}) do
  # end

  # defp _execute(["date_from_now"|_], machine=%Machine{}) do
  # end

  @compile {:inline, _convert_date: 1}
  def _convert_date(arg) do
    case NaiveDateTime.from_iso8601(arg) do
      {:ok, datetime} -> datetime
      {:error, _} ->
        case Date.from_iso8601(arg) do
          {:error, _} -> {:error, %DateConversionError{date: arg}}
          {:ok, date} ->
            with {:ok, datetime} <- NaiveDateTime.new(date, ~T[00:00:00.000]), do: datetime
        end
    end
  end

end

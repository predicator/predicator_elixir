defmodule Predicator.Evaluator.Date do
  @moduledoc false
  alias Predicator.{
    Machine,
    DateConversionError
  }

  def _execute(["to_date"|_], machine=%Machine{stack: [date|_rest_of_stack]}) do
    Machine.replace_stack(machine, _convert_date(date))
  end

  def _execute(["date_ago"|_], machine=%Machine{stack: [date_in_seconds|_rest_of_stack]}) do
    with {:ok, dt_from_stack} <- DateTime.from_unix(date_in_seconds),
         diff_in_seconds <- DateTime.diff(DateTime.utc_now, dt_from_stack),
         {:ok, datetime} <- DateTime.from_unix(diff_in_seconds)
    do
      Machine.replace_stack(machine, datetime)
    end
  end

  def _execute(["date_from_now"|_], machine=%Machine{stack: [seconds_from_now|_rest_of_stack]}) do
    date_from_now =
      DateTime.utc_now
      |> DateTime.to_unix
      |> add(seconds_from_now)

    Machine.replace_stack(machine, date_from_now)
  end


  @compile {:inline, _convert_date: 1}
  def _convert_date(arg) when is_number(arg), do: DateTime.from_unix!(arg)
  def _convert_date(arg) do
    case NaiveDateTime.from_iso8601(arg) do
      {:ok, naivedate} ->
        with {:ok, datetime} <- DateTime.from_naive(naivedate, "Etc/UTC"),
          do: datetime
      {:error, _} ->
        case Date.from_iso8601(arg) do
          {:error, _} -> {:error, %DateConversionError{date: arg}}
          {:ok, date} ->
            with {:ok, naivedate} <- NaiveDateTime.new(date, ~T[00:00:00.000]),
                 {:ok, datetime} <- DateTime.from_naive(naivedate, "Etc/UTC"),
              do: datetime
        end
    end
  end

  defp add(now, seconds_from_now), do: now + seconds_from_now
end

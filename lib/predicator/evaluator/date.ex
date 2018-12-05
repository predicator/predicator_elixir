defmodule Predicator.Evaluator.Date do
  @moduledoc false
  alias Predicator.{
    Machine,
    DateConversionError
  }


  def _execute(["to_date"|_], m=%Machine{stack: [date|rest_of_stack]}) do
    mach =
      %Machine{m| stack: [_convert_date(date)|rest_of_stack], ip: m.ip + 1 }

    mach
    |> Predicator.Evaluator._next_ip()
    |> Predicator.Evaluator._execute(mach)
  end

  # [["load", "created_at"], ["to_date"], ["lit", 259200], ["date_ago"], ["compare", "LT"]]
  def _execute(["date_ago"|_], m=%Machine{stack: [date_in_seconds|rest_of_stack]}) do
    with {:ok, dt_from_stack} <- DateTime.from_unix(date_in_seconds),
         diff_in_seconds <- DateTime.diff(DateTime.utc_now, dt_from_stack),
         {:ok, datetime} <- DateTime.from_unix(diff_in_seconds)
    do
      mach =
        %Machine{m|stack: [datetime|rest_of_stack], ip: m.ip + 1 }

      Predicator.Evaluator._next_ip(mach)
      |> Predicator.Evaluator._execute(mach)
    end
  end

  def _execute(["date_from_now"|_], m=%Machine{stack: [seconds_from_now|rest_of_stack]}) do
    date_from_now =
      DateTime.utc_now
      |> DateTime.to_unix
      |> add(seconds_from_now)

    mach =
      %Machine{m|stack: [date_from_now|rest_of_stack], ip: m.ip + 1 }

    Predicator.Evaluator._next_ip(mach)
    |> Predicator.Evaluator._execute(mach)
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

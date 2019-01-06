defmodule AdventOfCode.Day4 do
  def calculate_sleep_strategy2(inputs) do
    {_, guard_sleep_hours} =
      inputs
      |> Enum.sort(&(compare_events(&1, &2) == :lt))
      |> Enum.reduce(
        {"#id", %{}},
        fn x, acc ->
          handle_guard_action(x, acc)
        end
      )

    guard_sleep_hours
    |> Enum.reduce(%{}, fn {guard_id, {_, sleep_hours}}, acc ->
      Enum.reduce(sleep_hours, acc, fn {sleep, wake}, acc ->
        for s <- sleep..(wake - 1), into: acc do
          case Map.fetch(acc, {guard_id, s}) do
            {:ok, val} -> {{guard_id, s}, val + 1}
            _ -> {{guard_id, s}, 1}
          end
        end
      end)
    end)
    |> IO.inspect()
    |> Enum.max_by(fn {_k, v} -> v end)
  end

  def calculate_sleep(inputs) do
    {_, guard_sleep_hours} =
      inputs
      |> Enum.sort(&(compare_events(&1, &2) == :lt))
      |> Enum.reduce(
        {"#id", %{}},
        fn x, acc ->
          handle_guard_action(x, acc)
        end
      )

    {most_slept_guard, {most_sleep, most_sleep_hours}} =
      guard_sleep_hours
      |> Enum.max_by(fn {_, {total_sleep, _}} -> total_sleep end)

    {most_slept_minute, _} =
      most_sleep_hours
      |> Enum.reverse()
      |> Enum.reduce(%{}, fn {sleep, wake}, acc ->
        for s <- sleep..wake, into: acc do
          case Map.fetch(acc, s) do
            {:ok, val} -> {s, val + 1}
            _ -> {s, 1}
          end
        end
      end)
      |> Enum.max_by(fn {_k, v} -> v end)

    {most_slept_guard, most_slept_minute}
  end

  def parse_input_file(file_name) do
    with {:ok, input_text} <- File.read(file_name) do
      String.split(input_text, "\n", trim: true) |> Enum.map(&parse_line(&1))
    end
  end

  defp handle_guard_action({:begin_shift, date_time, {guard_id}}, {_guard_id, guard_sleep_hours}) do
    {guard_id, Map.update(guard_sleep_hours, guard_id, {0, []}, & &1)}
  end

  defp handle_guard_action({:fall_asleep, date_time, _data}, {guard_id, guard_sleep_hours}) do
    {guard_id,
     Map.update!(
       guard_sleep_hours,
       guard_id,
       fn {total_sleep, sleep_hours} ->
         {total_sleep - date_time.minute, [{date_time.minute} | sleep_hours] |> List.flatten()}
       end
     )}
  end

  defp handle_guard_action({:wake_up, date_time, _data}, {guard_id, guard_sleep_hours}) do
    {guard_id,
     Map.update!(
       guard_sleep_hours,
       guard_id,
       fn {total_sleep, [{last_sleep} | sleep_hours]} ->
         {total_sleep + date_time.minute,
          [{last_sleep, date_time.minute} | sleep_hours] |> List.flatten()}
       end
     )}
  end

  defp compare_events({_type1, dt1, _data1}, {_type2, dt2, _data2}) do
    DateTime.compare(dt1, dt2)
  end

  defp parse_line(<<
         "[",
         date_time::binary-size(16),
         "] Guard #",
         guard_id::binary
       >>) do
    {
      :begin_shift,
      NaiveDateTime.from_iso8601!(date_time <> ":00")
      |> DateTime.from_naive!("Etc/UTC"),
      {String.split(guard_id, " ", trim: true) |> Enum.fetch!(0)}
    }
  end

  defp parse_line(<<"[", date_time::binary-size(16), "] falls asleep">>) do
    {
      :fall_asleep,
      NaiveDateTime.from_iso8601!(date_time <> ":00")
      |> DateTime.from_naive!("Etc/UTC"),
      {}
    }
  end

  defp parse_line(<<"[", date_time::binary-size(16), "] wakes up">>) do
    {
      :wake_up,
      NaiveDateTime.from_iso8601!(date_time <> ":00")
      |> DateTime.from_naive!("Etc/UTC"),
      {}
    }
  end
end

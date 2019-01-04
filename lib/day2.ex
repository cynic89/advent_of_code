defmodule AdventOfCode.Day2 do
  def differ_by_one_letter(file) do
    file
    |> file_to_strings
    |> Enum.sort()
    |> Enum.reduce_while({"some_randafsdfsafafsfsdf"}, fn x, {acc} ->
      case is_close(x, acc) do
        {true, diff} ->
          IO.inspect("halting")
          {:halt, {x, acc, diff}}

        _ ->
          {:cont, {x}}
      end
    end)
  end

  def sum_two_three_lettered_alphabets(file) do
    file
    |> file_to_strings
    |> Enum.reduce(%{two: 0, three: 0}, fn x, acc ->
      Map.merge(acc, two_three_lettered_alphabets(x), fn _k, v1, v2 -> v1 + v2 end)
    end)
    |> hash
  end

  defp is_close(str1, str2) do
    diff =
      List.myers_difference(
        String.split(str1, "", trim: true),
        String.split(str2, "", trim: true)
      )
      |> Keyword.get_values(:del)

    {Enum.count(diff) <= 1, diff}
  end

  defp hash(two_three_letter_count) do
    Map.get(two_three_letter_count, :two) * Map.get(two_three_letter_count, :three)
  end

  defp two_three_lettered_alphabets(word) when is_binary(word) do
    word
    |> String.split("", trim: true)
    |> Enum.reduce(%{}, fn x, acc -> acc |> Map.update(x, 1, &(&1 + 1)) end)
    |> Enum.reduce(%{two: 0, three: 0}, fn {k, v}, acc ->
      case v do
        2 -> Map.update(acc, :two, 0, &(&1 * 0 + 1))
        3 -> Map.update(acc, :three, 0, &(&1 * 0 + 1))
        _ -> acc
      end
    end)
  end

  def file_to_strings(file_name) do
    with {:ok, input_text} <- File.read(file_name) do
      String.split(input_text, "\n", trim: true)
    end
  end
end

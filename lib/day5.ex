defmodule AdventOfCode.Day5 do
  def polymers_optimized(text) do
    codepoints = String.to_charlist(text)

    65..91
    |> Enum.map(fn x ->
      Enum.filter(codepoints, &(!(&1 == x || &1 == x + 32)))
      |> do_polymers(['0'])
    end)
    |> Enum.min()
  end

  def polymers(text) do
    do_polymers(String.to_charlist(text), ['0'])
  end

  defp do_polymers(codepoints, []) do
    codepoints |> Enum.count()
  end

  defp do_polymers(codepoints, removed) do
    {codepoints_new, removed_new, _} =
      codepoints
      |> Enum.reduce({[], [], 0}, fn x, {cp, rem, last_read} ->
        if abs(x - last_read) == 32 do
          {tl(cp), [[last_read, x] | rem], 0}
        else
          {[x | cp], rem, x}
        end
      end)

    do_polymers(Enum.reverse(codepoints_new), removed_new)
  end

  def parse_input_file(file_name) do
    with {:ok, input_text} <- File.read(file_name) do
      input_text
    end
  end
end

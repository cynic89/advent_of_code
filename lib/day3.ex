defmodule AdventOfCode.Day3 do
  def uniq_claim(claims, grid) do
    claims |> Enum.find(&is_claim_uniq(&1, grid))
  end

  def common_claims(grid) do
    grid |> Enum.count(fn {_k, v} -> v > 1 end)
  end

  def fill_grid(coordinates) do
    coordinates |> Enum.reduce(%{}, &do_fill_grid(&1, &2))
  end

  def file_to_strings(file_name) do
    with {:ok, input_text} <- File.read(file_name) do
      String.split(input_text, "\n", trim: true) |> Enum.map(&parse_input(&1))
    end
  end

  defp is_claim_uniq({_claim_id, {start_x, start_y}, {end_x, end_y}}, grid) do
    common_points =
      for x <- start_x..end_x, y <- start_y..end_y, Map.fetch!(grid, {x, y}) > 1, do: {x, y}

    Enum.count(common_points) == 0
  end

  defp do_fill_grid({_claim_id, {start_x, start_y}, {end_x, end_y}}, grid) do
    grid =
      for x <- start_x..end_x,
          y <- start_y..end_y,
          into: grid do
        case Map.fetch(grid, {x, y}) do
          {:ok, val} -> {{x, y}, val + 1}
          _ -> {{x, y}, 1}
        end
      end

    grid
  end

  defp parse_input(str_line) do
    {claim_id, _, start, size} = str_line |> String.split(" ", trim: true) |> List.to_tuple()

    {start_x, start_y} =
      start
      |> String.split(":")
      |> Enum.fetch!(0)
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()

    {size_x, size_y} =
      size |> String.split("x") |> Enum.map(&String.to_integer/1) |> List.to_tuple()

    {claim_id, {start_x, start_y}, {start_x + size_x - 1, start_y + size_y - 1}}
  end
end

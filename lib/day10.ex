defmodule AdventOfCode.Day10 do
  def decode_message(points_and_velocities, start_second, end_second) do
   y_range =  start_second..end_second
    |> Enum.map(fn current_second ->
      points =
        points_and_velocities
        |> Enum.map(fn {{x, y}, {vx, vy}} ->
          {x + (vx * current_second), y + (vy * current_second)}
        end)

      {{start_x, start_y}, {end_x, end_y}} = border = border(points)
      grid = fill_grid(points, border)
      layout = draw_grid_fast(grid, border)
      IO.puts(layout)
#      :timer.sleep(1000)
      {current_second, (end_y - start_y), (end_x - start_x)}
    end)

#   sort y range because the message will appear when the y range is minimum. Otherwise it'll be slow
    Enum.sort(y_range, fn {_, range1, _}, {_, range2, _} -> range1<range2  end) |> Enum.take(10)

  end

  defp fill_grid(points, border = {{start_x, start_y}, {end_x, end_y}}) do
    #    empty_grid = for x <- start_x..end_x, y <- start_y..end_y, into: Map.new do
    #      {{x, y}, 0}
    #    end
    empty_grid = Map.new()
    points |> Enum.reduce(empty_grid, fn x, acc -> Map.put(acc, x, 1) end)
  end

  defp draw_grid_fast(grid, border = {{start_x, start_y}, {end_x, end_y}}) do
    grouped_grid =
      grid
      |> Enum.group_by(fn {{x, y}, _} -> y end, fn {{x, y}, _} -> x end)
      |> Enum.sort()
#      |> IO.inspect()

    {_, row_vals} =
      Enum.reduce(grouped_grid, {0, []}, fn {y, x_coordinates}, {last_y, col_val} ->
        offset_y = y - start_y
        row = String.pad_leading("", offset_y - last_y, "\n")

        row =
          Enum.map(x_coordinates, &(&1 - start_x)) |> Enum.sort
          |> Enum.reduce({-1, row}, fn x, {last_x, row_val} ->
            hash_val = String.pad_trailing("", x - last_x - 1) <> "#"
            {x, row_val<>hash_val}
          end)

        {offset_y, [row | col_val]}
      end)

    row_vals |> Enum.map(fn {_, row} -> row end) |> Enum.reverse()
  end

  defp draw_grid(grid, border = {{start_x, start_y}, {end_x, end_y}}) do
    layout =
      for x <- start_x..end_x, y <- start_y..end_y do
        to_append = if y == start_y, do: "\n", else: ""

        to_append =
          case Map.fetch(grid, {x, y}) do
            {:ok, _} -> to_append <> "# "
            _ -> to_append <> ". "
          end
      end
  end

  defp offset(points, border = {{start_x, start_y}, _}) do
    points |> Enum.map(fn {x, y} -> {x - start_x, y - start_y} end)
  end

  defp border(points) do
    {{start_x, _}, {end_x, _}} = Enum.min_max_by(points, &elem(&1, 0))
    {{_, start_y}, {_, end_y}} = Enum.min_max_by(points, &elem(&1, 1))

    {{start_x, start_y}, {end_x, end_y}}
  end

  #  position=< 9,  1> velocity=< 0,  2>

  def parse_input_file(file_name) do
    with {:ok, input_text} <- File.read(file_name) do
      input_text |> String.split("\n", trim: true) |> Enum.map(&parse_line(&1))
    end
  end

  defp parse_line(<<"position=", rest::binary>>) do
    position_and_velocity = String.split(rest, "velocity=") |> Enum.map(&extract_val(&1))
    {Enum.fetch!(position_and_velocity, 0), Enum.fetch!(position_and_velocity, 1)}
  end

  defp extract_val(str) do
    vals =
      str
      |> String.trim()
      |> String.slice(1..-2)
      |> String.split(",", trim: true)
      |> Enum.map(fn x -> String.trim(x) |> String.to_integer() end)

    {Enum.fetch!(vals, 0), Enum.fetch!(vals, 1)}
  end
end

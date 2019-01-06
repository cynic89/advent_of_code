defmodule AdventOfCode.Day6 do
  def safe_region(inputs, max_dist) do
    grid_region_within(inputs, max_dist) |> Enum.count()
  end

  def largest_area(grid) do
    infinite_points =
      grid
      |> Enum.filter(fn {_, {type, _}} -> type == :infinite end)
      |> Enum.reduce([], fn {_, {_, cp}}, acc -> [cp | acc] end)
      |> List.flatten()

    grid
    |> Enum.filter(fn {_k, {_, v}} -> Enum.count(v) == 1 end)
    |> Enum.reduce(%{}, fn {pt, {_, [closest]}}, acc ->
      Map.update(acc, closest, 1, fn val -> val + 1 end)
    end)
    |> Enum.filter(fn {p, _} -> !Enum.member?(infinite_points, p) end)
    |> Enum.max_by(fn {_, v} -> v end)
  end

  def fill_grid(inputs) do
    inputs |> do_fill_grid
  end

  def parse_input_file(file_name) do
    with {:ok, input_text} <- File.read(file_name) do
      input_text
      |> String.split("\n", trim: true)
      |> Enum.map(fn x ->
        String.split(x, ",", trim: true)
        |> Enum.map(fn x -> String.trim(x) |> String.to_integer() end)
        |> List.to_tuple()
      end)
    end
  end

  defp grid_region_within(points, max_dist) do
    {{startx, starty}, {endx, endy}} = border_coordinates(points)

    for x <- startx..endx, y <- starty..endy do
      Enum.reduce(points, 0, fn pt, acc -> acc + manhattan_distance(pt, {x, y}) end)
    end
    |> Enum.filter(&(&1 < max_dist))
  end

  defp do_fill_grid(points) do
    {{startx, starty}, {endx, endy}} = border_coordinates(points)

    for x <- startx..endx, y <- starty..endy do
      {_dist, closest_points} = closest({x, y}, points)

      if x == startx || x == endx || (y == starty || y == endy) do
        {{x, y}, {:infinite, closest_points}}
      else
        {{x, y}, {:finite, closest_points}}
      end
    end
  end

  defp infinite_points(grid) do
  end

  defp closest(grid_point, points) do
    points
    |> Enum.reduce({10000, []}, fn x, {min_dist, closest_points} ->
      distance = manhattan_distance(grid_point, x)

      case distance - min_dist do
        0 -> {distance, [x | closest_points]}
        d when d < 0 -> {distance, [x]}
        d when d > 0 -> {min_dist, closest_points}
      end
    end)
  end

  defp border_coordinates(inputs) do
    {{startx, _}, {endx, _}} = Enum.min_max_by(inputs, &elem(&1, 0))
    {{_, starty}, {_, endy}} = Enum.min_max_by(inputs, &elem(&1, 1))

    {{startx, starty}, {endx, endy}}
  end

  defp manhattan_distance({p1, p2}, {m1, m2}) do
    abs(p1 - m1) + abs(p2 - m2)
  end
end

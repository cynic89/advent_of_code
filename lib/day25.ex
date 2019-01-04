defmodule AdventOfCode.Day25 do
  def constellations(normalized_points) do
    sorted_points =
      normalized_points |> Enum.sort(&(manhattan_distance(&1) <= manhattan_distance(&2)))

    sorted_points
    #    |> IO.inspect()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {x, index}, acc ->
      constellation_coordinates = find_constellation_coordinates(x, index, sorted_points)
      update_constellation(x, constellation_coordinates, acc)
    end)
    |> IO.inspect()
    |> Enum.uniq()
    |> Enum.count()
  end

  defp update_constellation(point, constellation_coordinates, constellations) do
    case Enum.filter(constellations, fn {k, v} -> belongs_to?(v, constellation_coordinates) end) do
      [] ->
        Map.put(constellations, point, constellation_coordinates |> List.flatten() |> Enum.uniq())

      [{parent, _parent_coords} | constellations_to_merge] ->
        constellations_to_merge
        |> Enum.reduce(constellations, fn {ck, cv}, acc ->
          Map.update!(
            acc,
            parent,
            &[&1 | [cv]]
          )
          |> Map.delete(ck)
        end)
        |> Map.update!(
          parent,
          &([&1 | [constellation_coordinates]] |> List.flatten() |> Enum.uniq())
        )

      _ ->
        throw(point)
    end
  end

  defp belongs_to?(existing_constellation, new_coordinates) do
    Enum.any?(new_coordinates, fn x ->
      Enum.any?(
        existing_constellation,
        fn c -> manhattan_distance(x, c) <= 3 end
      )
    end)
  end

  defp find_constellation_coordinates(x, index, sorted_points) do
    Enum.slice(sorted_points, index..-1)
    |> Enum.reduce_while([x], fn e, acc ->
      if abs(manhattan_distance(x) - manhattan_distance(e)) > 3 do
        {:halt, acc}
      else
        if manhattan_distance(x, e) <= 3 do
          {:cont, [e | acc]}
        else
          {:cont, acc}
        end
      end
    end)
  end

  def normalize(points) do
    {m1, m2, m3, m4} =
      points
      |> Enum.reduce({0, 0, 0, 0}, fn p, acc ->
        min_coordinates(p, acc)
      end)

    points
    |> Enum.map(fn {p1, p2, p3, p4} -> {p1 - m1, p2 - m2, p3 - m3, p4 - m4} end)
    |> IO.inspect()
  end

  def file_to_points(file_name) do
    with {:ok, input_text} <- File.read(file_name) do
      String.split(input_text, "\n", trim: true)
      |> Enum.map(fn x ->
        String.split(x, ",", trim: true)
        |> Enum.reduce({}, fn x, acc -> Tuple.append(acc, String.to_integer(x)) end)
      end)
    end
  end

  defp min_coordinates({p1, p2, p3, p4}, {m1, m2, m3, m4}) do
    {min(p1, m1), min(p2, m2), min(p3, m3), min(p4, m4)}
  end

  defp manhattan_distance(p) do
    manhattan_distance(p, {0, 0, 0, 0})
  end

  defp manhattan_distance({p1, p2, p3, p4}, {m1, m2, m3, m4}) do
    abs(p1 - m1) + abs(p2 - m2) + abs(p3 - m3) + abs(p4 - m4)
  end
end

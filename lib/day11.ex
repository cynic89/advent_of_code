defmodule AdventOfCode.Day11 do
  def most_powerful_square(size \\ 300, serial_no) do
    power_grid(size, serial_no)
    |> sum_squares
    |> Enum.max_by(fn {k, {s, v}} -> v end)
  end

  def sum_squares(size \\ 300, power_grid) do
    options = [
      max_concurrency: System.schedulers_online() * 2,
      timeout: :infinity,
      ordered: false
    ]

    tasks =
      1..size
      |> Task.async_stream(
        fn x ->
          {:ok, row_max} =
            1..size
            |> Task.async_stream(
              fn y ->
                sum_squares = sum_squares_max(x, y, size, power_grid)
                {{x, y}, sum_squares}
              end,
              options
            )
            |> Enum.max_by(fn {:ok, {_, {_s, v}}} -> v end)

          row_max
        end,
        options
      )

    IO.puts("Tasks Created")

    highest_row_sum_grid =
      tasks
      |> Enum.map(&IO.inspect(&1))
      |> Enum.reduce(%{}, fn val, acc ->
        {:ok, {{x, y}, {size, sum}}} = val
        Map.put(acc, {x, y}, {size, sum})
      end)
      |> IO.inspect()

    highest_row_sum_grid |> Enum.max_by(fn {k, {_s, sum}} -> sum end)
  end

  defp sum_squares_max(x, y, size, power_grid) do
    limit = size - max(x, y) + 1

    1..limit
    |> Stream.map(fn s -> {s, sum_squares(x, y, s, power_grid)} end)
    |> Enum.max_by(fn {_, sum} -> sum end)
  end

  defp sum_squares(x, y, size, power_grid) do
    power_vals =
      for inner_x <- x..(x + size - 1),
          inner_y <- y..(y + size - 1),
          do: Map.fetch!(power_grid, {inner_x, inner_y})

    power_vals |> Enum.sum()
  end

  def sum_squares_3x3(size \\ 300, power_grid) do
    for x <- 1..(size - 2), y <- 1..(size - 2), into: Map.new() do
      sum_squares =
        for inner_x <- x..(x + 2),
            inner_y <- y..(y + 2),
            do: Map.fetch!(power_grid, {inner_x, inner_y})

      {{x, y}, sum_squares |> Enum.sum()}
    end
  end

  def power_grid(size, serial_no) do
    for x <- 1..size, y <- 1..size, into: Map.new() do
      rack_id = x + 10
      power_level = rack_id * y
      power_level = power_level + serial_no
      power_level = power_level * rack_id
      power_level = rem(div(power_level, 100), 10)
      power_level = power_level - 5

      {{x, y}, power_level}
    end
  end
end

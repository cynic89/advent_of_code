defmodule AdventOfCode.Day1 do
  @moduledoc """
  Documentation for AdventOfCode.Day1.
  """

  @doc """
  Run.

  ## Examples

      iex> AdventOfCode.Day1.run("")
      3

  """
  def run(file_name) do
    file_name |> file_to_integers |> sum_frequencies
  end

  def find_first_duplicate_frequency(file_name) do
    file_name
    |> file_to_integers
    |> Stream.cycle()
    |> Enum.reduce_while(%{0 => true, last_frequency: 0}, fn x, acc ->
      last_frequency = acc |> Map.get(:last_frequency)
      resulting_frequency = x + last_frequency

      unless Map.get(acc, resulting_frequency) == nil do
        IO.inspect("halting")
        IO.inspect(resulting_frequency)
        {:halt, Map.put_new(acc, :result, resulting_frequency)}
      else
        {:cont,
         acc
         |> Map.put_new(resulting_frequency, true)
         |> Map.put(:last_frequency, resulting_frequency)}
      end
    end)
    |> Map.fetch(:result)
  end

  @doc """
  Sum Frequencies.

  ## Examples

      iex> AdventOfCode.Day1.sum_frequencies([+1, -1 , +3])
      3

  """
  def sum_frequencies(frequencies) do
    Enum.reduce(frequencies, 0, fn x, acc -> x + acc end)
  end

  def file_to_integers(file_name) do
    with {:ok, input_text} <- File.read(file_name) do
      String.split(input_text, "\n", trim: true) |> Enum.map(&String.to_integer/1)
    end
  end
end

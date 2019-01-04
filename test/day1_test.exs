defmodule AdventOfCode.Day1Test do
  use ExUnit.Case
  doctest AdventOfCode.Day1

  test "sums frequencies" do
    assert AdventOfCode.Day1.sum_frequencies([+1, -1, 3]) == 3
  end

  test "parses file to integer list" do
    assert AdventOfCode.Day1.file_to_integers("/tmp/input.txt") == [+1, -1, 3]
  end
end

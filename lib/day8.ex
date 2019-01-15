defmodule AdventOfCode.Day8 do
  def build_tree(str) do
    nos = String.split(str) |> Enum.map(&String.to_integer/1) |> IO.inspect()
    {node, _} = build_node(nos)
    node |> root_value(0)
  end

  defp sum_metadata(tree) do
    sum_metadata(tree, 0)
  end

  defp sum_metadata({children, metadata}, acc) do
    c = Enum.reduce(children, 0, &sum_metadata(&1, &2))
    c + Enum.sum(metadata) + acc
  end

  defp root_value({[], metadata}, acc) do
    Enum.sum(metadata) + acc
  end

  defp root_value({children, metadata}, acc) do
    c =
      Enum.reduce(metadata, 0, fn m, acc ->
        case Enum.fetch(children, m - 1) do
          {:ok, reference_child} ->
            IO.inspect("Found")
            IO.inspect(reference_child)
            root_value(reference_child, acc)

          _ ->
            acc
        end
      end)

    c + acc
  end

  #  2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2

  defp build_node([children_count, metadata_count | rest]) do
    {children, rest} = children(children_count, rest, [])

    {metadata, rest} = Enum.split(rest, metadata_count)
    {{children, metadata}, rest}
  end

  defp children(0, rest, acc) do
    {Enum.reverse(acc), rest}
  end

  defp children(children_count, rest, acc) do
    {node, rest} = build_node(rest)
    children(children_count - 1, rest, [node | acc])
  end
end

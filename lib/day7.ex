defmodule AdventOfCode.Day7 do
  def step_time(steps, no_of_workers) do
    {:root, nodes} =
      steps
      |> Enum.reduce({:root, []}, fn {p, c}, acc ->
        {_, child} = find_node(c, acc)
        node_to_update = {p, child}
        build_tree(node_to_update, acc)
      end)

    grouped_steps =
      breadth_traverse([{:root, nodes, 0}], [])
      |> Enum.uniq_by(fn {e, _} -> e end)
      |> Enum.reverse()
      |> IO.inspect()
      |> Enum.sort(fn {x, xheight}, {y, yheight} -> xheight <= yheight end)
      |> Enum.group_by(fn {_, ht} -> ht end)
      |> Map.delete(0)
      |> IO.inspect()

    worker_steps = 1..no_of_workers |> Enum.reduce(%{}, &Map.put(&2, &1, []))

    grouped_steps
    |> Enum.reduce(worker_steps, fn {_, steps}, acc ->
      steps
      |> Enum.sort(fn {x, _}, {y, _} -> x < y end)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {{step, height}, index}, worker_steps ->
        if index == 0 do
          Map.update!(worker_steps, 1, &[{step, height, index} | &1])
        else
          {free_worker_id, _} =
            worker_steps
            |> Enum.map(fn w = {wid, wsteps} -> {wid, worker_recent_steps(w, height)} end)
            |> Enum.min_by(fn {_, worker_recent_steps} -> worker_recent_steps end)

          Map.update!(worker_steps, free_worker_id, &[{step, height, index} | &1])
        end
      end)
    end)
    |> Enum.map(fn {k, v} -> {k, Enum.reverse(v)} end)
    |> IO.inspect()
    |> Enum.map(fn {wid, steps} -> {wid, sum_steps(steps)} end)
  end

  defp sum_steps(steps) do
    steps |> Enum.reduce(0, fn {step, _, _}, acc -> acc + to_codepoint(step) - 64 + 60 end)
  end

  defp worker_recent_steps({_, []}, _) do
    0
  end

  defp worker_recent_steps({worker_id, worker_steps}, current_height) do
    worker_steps
    |> Enum.filter(fn {step, height, _idx} -> height >= current_height - 1 end)
    |> Enum.reduce(0, fn {step, height, _idx}, acc -> acc + (to_codepoint(step) - 64 + 60) end)
  end

  defp to_codepoint(str) do
    <<cp, _>> = str <> <<0>>
    cp
  end

  def build_path(steps) do
    {:root, nodes} =
      steps
      |> Enum.reduce({:root, []}, fn {p, c}, acc ->
        {_, child} = find_node(c, acc)
        node_to_update = {p, child}
        build_tree(node_to_update, acc)
      end)

    pre_traverse({:root, nodes}, [], 0)
    |> Enum.uniq_by(fn {e, _} -> e end)
    |> Enum.reverse()
    |> Enum.sort(fn {x, xheight}, {y, yheight} ->
      if x > y do
        xheight < yheight
      else
        true
      end
    end)
    |> Enum.reduce("", fn {x, _}, acc -> unless x == :root, do: acc <> x, else: acc end)
  end

  defp pre_traverse({node, children}, acc, height) do
    c = Enum.reduce(children, [], &pre_traverse(&1, &2, height + 1))
    [c | [{node, height} | acc]] |> List.flatten()
  end

  defp breadth_traverse([], acc) do
    acc
  end

  defp breadth_traverse([h | t] = q, acc) do
    #      poll
    {temp_node, temp_children, ht} = h
    #      add_to_queue
    children_with_height = Enum.map(temp_children, fn {val, c} -> {val, c, ht + 1} end)
    pending_nodes = t ++ children_with_height
    breadth_traverse(pending_nodes, [{temp_node, ht} | acc])
  end

  defp build_tree(node = {val, child}, tree = {:root, children}) do
    case find_node(val, tree) do
      {:found, _} -> build_node(node, tree)
      _ -> {:root, [{val, [child]} | children] |> Enum.sort(fn {x, _}, {y, _} -> x < y end)}
    end
  end

  defp build_node(to_update = {new_node, new_child}, {new_node, children}) do
    updated_children = children(to_update, children, [])
    {new_node, Enum.sort([new_child | updated_children], fn {x, _}, {y, _} -> x < y end)}
  end

  defp build_node(to_update = {new_node, new_children}, {node, children}) do
    updated_children = children(to_update, children, [])
    {node, Enum.sort(updated_children, fn {x, _}, {y, _} -> x < y end)}
  end

  defp children(_, [], acc) do
    acc
  end

  defp children(to_update, [h | t], acc) do
    node = build_node(to_update, h)
    children(to_update, t, [node | acc])
  end

  defp find_node(val, node) do
    case do_find_node(val, node) do
      {:found, n} -> {:found, n}
      _ -> {:new, {val, []}}
    end
  end

  defp do_find_node(val, n = {val, children}) do
    {:found, n}
  end

  defp do_find_node(val, {other_val, children}) do
    find_children(val, children)
  end

  defp find_children(val, []) do
    :ok
  end

  defp find_children(val, [h | t]) do
    v = do_find_node(val, h)

    case v do
      {:found, _} -> v
      _ -> find_children(val, t)
    end
  end

  def parse_input_file(file_name) do
    with {:ok, input_text} <- File.read(file_name) do
      input_text
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line(&1))
    end
  end

  defp parse_line(<<
         "Step ",
         step1::binary-size(1),
         " must be finished before step ",
         step2::binary-size(1),
         " can begin."
       >>) do
    {step1, step2}
  end
end

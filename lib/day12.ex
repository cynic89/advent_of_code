defmodule AdventOfCode.Day12 do
  def future_pots({pots, notes}, no_of_generations) do
    {pad, pots} = pad_lead_pots(pots)
    {_, pots} = pad_trail_pots(pots)

    {pad, pots} =
      1..no_of_generations
      |> Enum.reduce({pad, pots}, fn _, {total_padding, pots} ->
        {padding, next_gen_pots} = next_gen_pots(pots, notes)
        {total_padding + padding, next_gen_pots}
      end)
      |> IO.inspect()

    Enum.with_index(pots)
    |> Enum.reduce(0, fn {p, index}, sum ->
      if p == ?# do
        sum + (pad * -1 + index)
      else
        sum
      end
    end)
  end

  def future_pots_fast({pots, notes}, no_of_generations) do
    {pad, pots} = pad_lead_pots(pots)
    {_, pots} = pad_trail_pots(pots)

    {pad, pots} =
      1..no_of_generations
      |> Enum.reduce({pad, pots}, fn _, {total_padding, next_gen_pots} ->
        {padding, next_gen_pots} = next_gen_pots_fast(next_gen_pots, notes)
        {total_padding + padding, next_gen_pots}
      end)
      |> IO.inspect()

    Enum.with_index(pots)
    |> Enum.reduce(0, fn {p, index}, sum ->
      if p == ?# do
        sum + (pad * -1 + index)
      else
        sum
      end
    end)
  end

  defp next_gen_pots(curr_gen_pots, notes) do
    next_gen_pots =
      Enum.with_index(curr_gen_pots) |> Enum.map(&calc_next_gen_pot(&1, curr_gen_pots, notes))

    {pad, pots} = pad_lead_pots(next_gen_pots)
    {_, pots} = pad_trail_pots(pots)
    {pad, pots}
  end

  defp next_gen_pots_fast(curr_gen_pots, notes) do
    [?., ?., ?., ?. | curr_gen_pots] = curr_gen_pots

    {_, next_gen_pots} =
      Enum.reduce(curr_gen_pots, {[?., ?., ?., ?.], []}, fn x, {prev, acc} ->
        note_key = [prev | [x]] |> List.flatten()

        acc =
          case Map.get(notes, List.to_string(note_key)) do
            "#" -> [?# | acc]
            _ -> [?. | acc]
          end

        {Enum.slice(note_key, 1, 4), acc}
      end)

    next_gen_pots =
      String.reverse(".." <> List.to_string(next_gen_pots) <> "..")
      |> String.to_charlist()
      |> List.flatten()

    #      next_gen_pots = [[?.,?.] | [ next_gen_pots  | [?.,?.]] ] |> List.flatten |> Enum.reverse

    {pad, pots} = pad_lead_pots(next_gen_pots)
    {_, pots} = pad_trail_pots(pots)

    {pad, pots}
  end

  defp pad_lead_pots(pots) do
    first_pot_index = Enum.find_index(pots, fn x -> x == ?# end)

    if first_pot_index < 4 do
      pad_lead_pots = (5 - 1)..(first_pot_index + 1) |> Enum.map(fn x -> ?. end)
      {5 - first_pot_index - 1, [pad_lead_pots | pots] |> List.flatten()}
    else
      to_slice = first_pot_index - 4

      {to_slice * -1, Enum.slice(pots, to_slice..-1)}
    end
  end

  defp pad_trail_pots(pots) do
    pots = Enum.reverse(pots)
    first_pot_index = Enum.find_index(pots, fn x -> x == ?# end)

    if first_pot_index < 4 do
      pad_lead_pots = (5 - 1)..(first_pot_index + 1) |> Enum.map(fn x -> ?. end)
      {5 - first_pot_index - 1, [pad_lead_pots | pots] |> Enum.reverse() |> List.flatten()}
    else
      {0, pots |> Enum.reverse() |> List.flatten()}
    end
  end

  defp calc_next_gen_pot({pot, index}, curr_gen_pots, notes) do
    pot_with_neighbours = Enum.slice(curr_gen_pots, index - 2, 5)

    case Map.get(notes, List.to_string(pot_with_neighbours)) do
      nil -> ?.
      <<next_gen_pot::utf8>> -> next_gen_pot
    end
  end

  defp calc_next_gen_pot_fast({pot, index}, curr_gen_pots, notes) do
    pot_with_neighbours = Enum.slice(curr_gen_pots, index - 2, 5)

    case Map.get(notes, List.to_string(pot_with_neighbours)) do
      nil -> ?.
      <<next_gen_pot::utf8>> -> next_gen_pot
    end
  end

  def parse_input_file(file_name) do
    with {:ok, input_text} <- File.read(file_name) do
      [initial_state_text | notes_text] = String.split(input_text, "\n", trim: true)

      initial_state =
        String.split(initial_state_text, "initial state: ", trim: true)
        |> Enum.fetch!(0)
        |> String.to_charlist()

      notes =
        Enum.reduce(notes_text, %{}, fn x, acc ->
          [note, val] = String.split(x, " => ")
          Map.put(acc, note, val)
        end)

      {initial_state, notes}
    end
  end
end

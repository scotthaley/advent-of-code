defmodule Day12 do
  def findCell(map, char) do
    map
    |> Enum.map(&Enum.with_index(&1))
    |> Enum.with_index()
    |> Enum.filter(fn {v, _} -> Enum.any?(v, fn {y, _} -> y == char end) end)
    |> Enum.at(0)
    |> then(fn {x, y} -> {Enum.find(x, nil, fn {v, _} -> v == char end), y} end)
    |> then(fn {{_, x}, y} -> {x, y} end)
  end

  def convertToHeight("S"), do: 0
  def convertToHeight("E"), do: 25

  def convertToHeight(char) do
    :binary.first(char) - 97
  end

  def heightAtPoint(map, {x, y}) do
    map
    |> Enum.at(y)
    |> Enum.at(x)
  end

  def heuristic(map, {x, y} = pos, {ex, ey} = endPos) do
    height = heightAtPoint(map, pos)
    heightEnd = heightAtPoint(map, endPos)
    (abs(x - ex) + abs(y - ey)) * 100 + (heightEnd - height)
  end

  def successors(map, {x, y} = pos, g, endPos) do
    startHeight = heightAtPoint(map, pos)
    yMax = Enum.count(map)
    xMax = Enum.count(Enum.at(map, 0))

    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> Enum.filter(fn {a, b} -> a >= 0 && b >= 0 && a < xMax && b < yMax end)
    |> Enum.filter(fn a -> heightAtPoint(map, a) - startHeight <= 1 end)
    |> Enum.map(fn a ->
      %{pos: a, f: heuristic(map, a, endPos) + g + 1000, p: pos, g: g + 1000}
    end)
  end

  def processAStar(%{:open => open} = state) when open == [] do
    put_in(state, [:found], false)
  end

  def processAStar(state) do
    map = state[:map]
    endPos = state[:end]
    open = state[:open]
    closed = state[:closed]

    {first, rest} =
      state[:open]
      |> Enum.sort_by(& &1.f)
      |> List.pop_at(0)

    s =
      first
      |> then(fn %{:pos => x, :g => g} -> successors(map, x, g, endPos) end)
      |> Enum.filter(fn %{:pos => a} -> !Enum.any?(open, fn %{:pos => b} -> a == b end) end)
      |> Enum.filter(fn %{:pos => a, :f => af} ->
        !Enum.any?(closed, fn %{:pos => b, :f => bf} -> a == b && bf <= af end)
      end)

    found = Enum.find(s, fn %{:pos => a} -> a == endPos end)

    if found != nil do
      state = put_in(state, [:open], rest ++ s)
      state = update_in(state, [:closed], &(&1 ++ [first]))
      put_in(state, [:found], found)
    else
      state = put_in(state, [:open], rest ++ s)
      update_in(state, [:closed], &(&1 ++ [first]))
    end
  end

  def countSteps(endState) do
    start = endState[:start]
    found = endState[:found]

    1..1000
    |> Enum.reduce_while({found[:p], [found[:pos]]}, fn _, {x, list} ->
      parent = Enum.find(endState[:closed], fn %{:pos => a} -> a == x end)

      case parent[:pos] do
        ^start -> {:halt, [parent[:pos] | list]}
        nil -> {:halt, list}
        _ -> {:cont, {parent[:p], [parent[:pos] | list]}}
      end
    end)
  end

  def countFromState(state) do
    endState =
      1..10000
      |> Enum.reduce_while(state, fn _, acc ->
        newState = processAStar(acc)

        case newState[:found] do
          nil -> {:cont, newState}
          _ -> {:halt, newState}
        end
      end)

    if endState[:found] == false || endState[:found] == nil do
      nil
    else
      steps = countSteps(endState)

      # state[:map]
      # |> Enum.with_index
      # |> Enum.each(fn {row, y} ->
      #   IO.write String.pad_leading(to_string(y), 2) <> ": "
      #   row
      #   |> Enum.with_index
      #   |> Enum.each(fn {cell, x} ->
      #     if Enum.any?(steps, fn a -> a == {x, y} end) do
      #       IO.write " *"
      #     else
      #       IO.write String.pad_leading(to_string(cell), 2)
      #     end
      #   end)
      #   IO.write "\n"
      # end)

      steps
      |> Enum.count()
    end
  end

  def exec(input) do
    map =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))

    startPos = findCell(map, "S")
    endPos = findCell(map, "E")

    map =
      map
      |> Enum.map(fn x -> Enum.map(x, &convertToHeight(&1)) end)

    startNode = %{pos: startPos, f: 0, g: 0}
    state = %{start: startPos, end: endPos, map: map, open: [startNode], closed: [], found: nil}

    map
    |> Enum.with_index
    |> Enum.reduce([], fn {row, y}, acc ->
      cells = row
      |> Enum.with_index
      |> Enum.reduce([], fn {_, x}, acc ->
        [{x, y} | acc]
      end)

      acc ++ cells
    end)
    |> Enum.filter(fn x -> heightAtPoint(map, x) == 0 end)
    |> Enum.with_index
    |> Enum.map(fn {x, i} ->
      n = put_in(state, [:start], x)
      startNode = %{pos: x, f: 0, g: 0}
      n = put_in(n, [:open], [startNode])
      IO.inspect to_string(i) <> " / 1136"
      countFromState(n)
    end)
    |> Enum.filter(fn x -> x != nil end)
    |> Enum.sort
    |> IO.inspect
  end
end

# Day12.exec(body)

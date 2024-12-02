defmodule Day9 do

  def moveHead([{hx, hy} | t], dir) do
    case dir do
      "R" -> [{hx + 1, hy} | t]
      "L" -> [{hx - 1, hy} | t]
      "U" -> [{hx, hy + 1} | t]
      "D" -> [{hx, hy - 1} | t]
    end
  end

  def moveTail(knots, index) do
    {hx, hy} = Enum.at(knots, index - 1)
    {tx, ty} = Enum.at(knots, index)

    xDiff = hx - tx
    yDiff = hy - ty

    tailPos = case {xDiff, yDiff} do
      {2, 0} -> {tx + 1, ty}
      {-2, 0} -> {tx - 1, ty}
      {0, 2} -> {tx, ty + 1}
      {0, -2} -> {tx, ty - 1}
      {1, 2} -> {tx + 1, ty + 1}
      {1, -2} -> {tx + 1, ty - 1}
      {-1, 2} -> {tx - 1, ty + 1}
      {-1, -2} -> {tx - 1, ty - 1}
      {2, 1} -> {tx + 1, ty + 1}
      {2, -1} -> {tx + 1, ty - 1}
      {-2, 1} -> {tx - 1, ty + 1}
      {-2, -1} -> {tx - 1, ty - 1}
      {2, 2} -> {tx + 1, ty + 1}
      {2, -2} -> {tx + 1, ty - 1}
      {-2, 2} -> {tx - 1, ty + 1}
      {-2, -2} -> {tx - 1, ty - 1}
      _ -> {tx, ty}
    end

    List.replace_at(knots, index, tailPos)
  end

  def testRender(knots) do
    20..-20
    |> Enum.each(fn y ->
      -20..20
      |> Enum.each(fn x ->
        k = Enum.find_index(knots, fn k -> k == {x, y}  end)
        case k do
          nil -> IO.write "."
          _ -> IO.write k
        end

      end)
      IO.write "\n"
    end)
  end

  def exec do
    {:ok, contents} = File.read("day9.txt")

    # start = [{0, 0}, {0, 0}, {0, 0}]
    start = 0..9
    |> Enum.map(fn _ -> {0, 0} end)

    contents
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.map(fn [d, num] -> {d, Integer.parse(num)} end)
    |> Enum.map(fn { d, {num, _} } -> {d, num} end)
    |> Enum.reduce([], fn {dir, num}, acc ->
      0..num - 1
      |> Enum.map(fn _ -> dir end)
      |> then(fn x -> acc ++ x end)
    end)
    |> Enum.reduce({start, MapSet.new()}, fn dir, {start, set} ->
      coord = moveHead(start, dir)
      coord = 1..(Enum.count(start) - 1)
      |> Enum.reduce(coord, fn c, a ->
        moveTail(a, c)
      end)

      t = Enum.at(coord, Enum.count(coord) - 1)

      # testRender(coord)
      # IO.puts "--------------------------"

      {coord, MapSet.put(set, t)}
    end)
    |> then(fn {_, set} -> Enum.count(set) end)
  end
end

Day9.exec

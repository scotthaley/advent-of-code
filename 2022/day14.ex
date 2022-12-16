defmodule Day14 do
  def parsePoint([l, r]) do
    {l, _} = Integer.parse(l)
    {r, _} = Integer.parse(r)

    {l, r}
  end

  def parseScan(line) do
    [{start, _} | _] =
      waypoints =
      line
      |> String.split(" -> ")
      |> Enum.map(&String.split(&1, ","))
      |> Enum.map(&parsePoint(&1))
      |> Enum.reduce({[], nil}, fn x, {list, last} ->
        case last do
          nil -> {list, x}
          _ -> {list ++ [{last, x}], x}
        end
      end)
      |> then(fn {list, _} -> list end)

    waypoints
    |> Enum.map(&listPoints(&1))
    |> List.flatten()
    |> then(&[start | &1])
  end

  def listPoints({{sx, sy}, {ex, ey}}) do
    # Skip starting point so it doesn't get duplicated
    cond do
      sx == ex -> sy..ey |> Enum.map(&{sx, &1}) |> Enum.slice(1..100)
      sy == ey -> sx..ex |> Enum.map(&{&1, sy}) |> Enum.slice(1..100)
    end
  end

  def testRock(rocks, point) do
    !Enum.any?(rocks, &(&1 == point))
  end

  def dropSand(rocks, {x, y}, lowest) do
    cond do
      # y > lowest -> {:infinity, nil}
      y == lowest - 1 -> {:ok, {x, y}}
      testRock(rocks, {x, y + 1}) -> dropSand(rocks, {x, y + 1}, lowest)
      testRock(rocks, {x - 1, y + 1}) -> dropSand(rocks, {x - 1, y + 1}, lowest)
      testRock(rocks, {x + 1, y + 1}) -> dropSand(rocks, {x + 1, y + 1}, lowest)
      true -> {:ok, {x, y}}
    end
  end

  def exec(input) do
    rocks =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&parseScan(&1))
      |> List.flatten()

    lowest =
      rocks
      |> Enum.sort(fn {_, y1}, {_, y2} -> y1 > y2 end)
      |> Enum.at(0)
      |> then(fn {_, y} -> y end)

    0..1000
    |> Enum.reduce_while(rocks, fn i, acc ->
      case dropSand(acc, {500, 0}, lowest) do
        {:ok, point} -> {:cont, acc ++ [point]}
        {:infinity, nil} -> {:halt, i}
      end
    end)
    |> IO.inspect()
  end

  def exec2(input) do
    rocks =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&parseScan(&1))
      |> List.flatten()

    lowest =
      rocks
      |> Enum.sort(fn {_, y1}, {_, y2} -> y1 > y2 end)
      |> Enum.at(0)
      |> then(fn {_, y} -> y + 2 end)

    0..100000
    |> Enum.reduce_while(rocks, fn i, acc ->
      {:ok, point} = dropSand(acc, {500, 0}, lowest)

      IO.puts to_string(i) <> ": " <> inspect(point)

      cond do
        point == {500, 0} -> {:halt, i + 1}
        true -> {:cont, [point] ++ acc}
      end
    end)
    |> IO.inspect()
  end
end

{:ok, contents} = File.read("day14.txt")
Day14.exec2(contents)

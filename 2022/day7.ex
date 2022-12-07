defmodule Day7 do

  def parseNum(num) do
    {a, _} = num
    |> Integer.parse

    a
  end

  def up(path) do
    split = path
    |> String.split("/", trim: true)

    split
    |> Enum.take(Enum.count(split) - 1)
    |> Enum.join("/")
    |> then(fn x -> "/" <> x <> "/" end)
  end


  def mapInsert({path, num}, map) do
    keys = path
    |> String.split("/", trim: true)
    |> Enum.map(fn x -> Access.key(x, %{count: 0}) end)


    cond do
      Enum.count(keys) > 0 ->
        newMap = put_in(map, keys, num)

        keys
        |> Enum.slice(0, Enum.count(keys) - 1)
        |> Enum.reduce([], fn
          cur, [] -> [[cur]]
          cur, [head | _] = acc -> [[cur | head] | acc]
        end)
        |> Enum.reduce(newMap, fn k, acc ->
          update_in(acc, Enum.reverse([Access.key(:count) | k]), &(&1 + num))
        end)

      true -> map
    end
  end

  # {"/bnl/sdkfj/", [{"/bnl/sdkfj/dskfj", 2343}]}

  def commandReduce(cur, {path, files}) do
    cd = Regex.run(~r/\$ cd (.*)/, cur)
    file = Regex.run(~r/(\d+) (.*)/, cur)

    case {cd, file} do
      {[_, "/"], nil} -> {"/", files}
      {[_, ".."], nil} -> {up(path), files}
      {[_, dir], nil} -> {path <> dir <> "/", files}
      {nil, [_, num, file]} -> {path, [{path <> file, parseNum(num)} | files]}
      _ -> {path, files}
    end
  end

  def getRootSize(map) do
    map
    |> Map.keys
    |> Enum.reduce(0, fn x, acc ->
      cond do
        is_map(map[x]) -> map[x][:count] + acc
        true -> map[x] + acc
      end
    end)
  end

  def flatMap(map) do
    dirs = map
    |> Map.keys
    |> Enum.filter(fn x -> is_map(map[x]) end)

    flat = dirs
    |> Enum.map(fn x -> {x, map[x][:count]} end)

    others = dirs
    |> Enum.reduce([], fn cur, acc -> acc ++ flatMap(map[cur]) end)

    flat ++ others
  end

  def exec do
    {:ok, contents} = File.read("day7.txt")

    contents
    |> String.split("\n", trim: true)
    |> Enum.reduce({"", []}, &commandReduce(&1, &2))
    |> then(fn {_, files} -> files end)
    |> Enum.reduce(%{}, &mapInsert(&1, &2))
    |> flatMap
    |> Enum.map(fn {_, count} -> count end)
    |> Enum.filter(fn c -> c <= 100000 end)
    |> Enum.sum
  end

  def exec2 do
    {:ok, contents} = File.read("day7.txt")

    map = contents
    |> String.split("\n", trim: true)
    |> Enum.reduce({"", []}, &commandReduce(&1, &2))
    |> then(fn {_, files} -> files end)
    |> Enum.reduce(%{}, &mapInsert(&1, &2))

    free = 70000000 - getRootSize(map)
    needed = 30000000 - free

    map
    |> flatMap
    |> Enum.map(fn {_, count} -> count end)
    |> Enum.filter(fn c -> c >= needed end)
    |> Enum.sort
    |> Enum.at(0)
  end
end

Day7.exec2


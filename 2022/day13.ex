defmodule Day13 do
  def comparePacket([l, r] = packet) do
    IO.write("- Compare " <> inspect(l) <> " vs " <> inspect(r) <> "\n")
    comparePacket(packet, 0)
  end

  def comparePacket([l, r], index, depth \\ 0) do
    lv = Enum.at(l, index)
    rv = Enum.at(r, index)

    0..depth
    |> Enum.each(fn _ -> IO.write("  ") end)

    IO.write("- Compare " <> inspect(lv) <> " vs " <> inspect(rv) <> "\n")

    cond do
      rv == nil && lv == nil ->
        :neutral

      lv == nil ->
        :ok

      rv == nil ->
        :bad

      is_integer(lv) && is_integer(rv) ->
        cond do
          lv < rv -> :ok
          lv > rv -> :bad
          lv == rv -> comparePacket([l, r], index + 1, depth)
        end

      is_list(lv) && is_list(rv) ->
        case comparePacket([lv, rv], 0, depth + 1) do
          :ok -> :ok
          :bad -> :bad
          :neutral -> comparePacket([l, r], index + 1, depth)
        end

      is_list(lv) ->
        case comparePacket([lv, [rv]], 0, depth + 1) do
          :ok -> :ok
          :bad -> :bad
          :neutral -> comparePacket([l, r], index + 1, depth)
        end

      is_list(rv) ->
        case comparePacket([[lv], rv], 0, depth + 1) do
          :ok -> :ok
          :bad -> :bad
          :neutral -> comparePacket([l, r], index + 1, depth)
        end
    end
  end

  def splitLine(line) do
    line
    |> String.slice(1..(String.length(line) - 2))
    |> String.split("", trim: true)
    |> Enum.reduce({[""], 0}, fn char, {list, level} ->
      [head | tail] = list

      case {char, level} do
        {"[", _} -> {[head <> char | tail], level + 1}
        {"]", _} -> {[head <> char | tail], level - 1}
        {",", 0} -> {["" | list], level}
        _ -> {[head <> char | tail], level}
      end
    end)
    |> then(fn {l, _} -> l end)
    |> Enum.reverse()
  end

  def parseArray(line) when line == "[]", do: []

  def parseArray(line) do
    line
    |> splitLine
    |> Enum.map(&parseLine(&1))
  end

  def parseLine(line) do
    case Integer.parse(line) do
      {num, _} -> num
      :error -> parseArray(line)
    end
  end

  def parsePacket(pair) do
    pair
    |> String.split("\n", trim: true)
    |> Enum.map(&parseLine(&1))
  end

  def exec(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parsePacket(&1))
    |> Enum.map(&comparePacket(&1))
    |> Enum.with_index()
    |> Enum.filter(fn {x, _} -> x == :ok end)
    |> Enum.map(fn {_, i} -> i + 1 end)
    |> Enum.sum()
  end

  def exec2(input) do
    list =
      input
      |> String.replace("\n\n", "\n")
      |> String.split("\n", trim: true)
      |> Enum.map(&parseLine(&1))

    sorted = (list ++ [[[2]], [[6]]])
    |> Enum.sort(fn a, b ->
      comparePacket([a, b]) == :ok
    end)
    |> Enum.with_index

    {_, key1} = Enum.find(sorted, fn {x, _} -> x == [[2]] end)
    {_, key2} = Enum.find(sorted, fn {x, _} -> x == [[6]] end)

    (key1 + 1) * (key2 + 1)
  end
end

Day13.exec2(body)

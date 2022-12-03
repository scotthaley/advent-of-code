defmodule Day3 do
  def findShared([a, b, c] = sacks, ai) do
    itemA = Enum.at(a, ai)
    foundB = Enum.find(b, fn x -> x == itemA end)
    foundC = Enum.find(c, fn x -> x == itemA end)

    cond do
      foundB != nil && foundC != nil -> itemA
      true -> findShared(sacks, ai + 1)
    end
  end

  def findShared({left, right} = compartments, leftI, rightI) do
    cond do
      Enum.at(left, leftI) == Enum.at(right, rightI) -> Enum.at(left, leftI)
      rightI == Enum.count(right) - 1 -> findShared(compartments, leftI + 1, 0)
      true -> findShared(compartments, leftI, rightI + 1)
    end
  end

  def findShared([a, b, c] = sacks) when is_list(sacks) do
    al = String.split(a, "", trim: true)
    bl = String.split(b, "", trim: true)
    cl = String.split(c, "", trim: true)

    findShared([al, bl, cl], 0)
  end

  def findShared(compartments) do
    findShared(compartments, 0, 0)
  end

  def splitSack(items) do
    count = trunc(Enum.count(items) / 2)
    left = Enum.slice(items, 0, count)
    right = Enum.slice(items, count, count)
    {left, right}
  end

  def priorityValue(item) when item >= 97 do
    item - 96
  end

  def priorityValue(item) when item < 97 do
    item - 38
  end

  def findPriority(sack) do
    sack
    |> String.split("", trim: true)
    |> splitSack
    |> findShared
    |> :binary.first
    |> priorityValue
  end

  def findBadgePriority(sacks) do
    sacks
    |> findShared
    |> :binary.first
    |> priorityValue
  end

  def exec do
    {:ok, contents} = File.read("day3.txt")

    contents
    |> String.split("\n", trim: true)
    |> Enum.map(fn sack -> findPriority sack end)
    |> Enum.sum
  end

  def exec2 do
    {:ok, contents} = File.read("day3.txt")

    contents
    |> String.split("\n", trim: true)
    |> Enum.chunk_every(3)
    |> Enum.map(fn sack -> findBadgePriority sack end)
    |> Enum.sum
  end
end

Day3.exec2

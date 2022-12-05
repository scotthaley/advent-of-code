defmodule Day4 do
  def splitPair(pair) do
    pair
    |> String.split(",")
    |> Enum.map(fn x -> x |> String.split("-") end)
    |> Enum.map(fn [l, r] -> {Integer.parse(l), Integer.parse(r)} end)
    |> Enum.map(fn {{l, _}, {r, _}} -> {l, r} end)
  end

  def doesOneContainOther({{l1, r1}, {l2, r2}}) do
    cond do
      l1 <= l2 && r1 >= r2 -> true
      l2 <= l1 && r2 >= r1 -> true
      true -> false
    end
  end

  def doesOneOverlapOther({{l1, r1}, {l2, r2}}) do
    cond do
      l2 <= l1 && l1 <= r2 -> true
      l2 <= r1 && r1 <= r2 -> true
      l1 <= l2 && l2 <= r1 -> true
      l1 <= r2 && r2 <= r1 -> true
      true -> false
    end
  end

  def exec do
    {:ok, contents} = File.read("day4.txt")

    contents
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> splitPair x end)
    |> Enum.map(fn [e1, e2] -> {e1, e2} end)
    |> Enum.filter(fn x -> doesOneOverlapOther x end)
    |> Enum.count
  end
end

Day4.exec

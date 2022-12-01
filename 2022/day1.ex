defmodule Day1 do
  def parseInt(number) do
    with {num, _} <- Integer.parse(number) do
      num
    else
      _ -> 0
    end
  end

  def sum(list) do
    sums = list
    |> String.split("\n")
    |> Enum.map(fn x -> parseInt x end)
    |> Enum.sum

    sums
  end

  def exec do
    {:ok, contents} = File.read("day1.txt")

    contents
    |> String.split("\n\n")
    |> Enum.map(fn x -> sum x end)
    |> Enum.sort
    |> Enum.reverse
    |> Enum.take(3)
    |> Enum.sum
  end
end

Day1.exec

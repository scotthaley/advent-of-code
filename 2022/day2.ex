defmodule Day2 do
  def scoreRound(line) do
    with [theirs, yours] <- line |> String.split(" ") do
      winLose(theirs, yours) + symbolScore(yours)
    else
      _ -> 0
    end
  end

  def scoreRoundPartTwo(line) do
    with [theirs, winLoseDraw] <- line |> String.split(" ") do
      yours = getMine(theirs, winLoseDraw)
      winLose(theirs, yours) + symbolScore(yours)
    else
      _ -> 0
    end
  end

  def winLose(theirs, yours) do
    case {theirs, yours} do
      {"A", "Y"} -> 6
      {"B", "Z"} -> 6
      {"C", "X"} -> 6
      {"A", "X"} -> 3
      {"B", "Y"} -> 3
      {"C", "Z"} -> 3
      _ -> 0
    end
  end

  def symbolScore(symbol) do
    case symbol do
      "X" -> 1
      "Y" -> 2
      "Z" -> 3
    end
  end

  def getMine(theirs, winLoseDraw) do
    case {theirs, winLoseDraw} do
      {"A", "X"} -> "Z"
      {"B", "X"} -> "X"
      {"C", "X"} -> "Y"
      {"A", "Y"} -> "X"
      {"B", "Y"} -> "Y"
      {"C", "Y"} -> "Z"
      {"A", "Z"} -> "Y"
      {"B", "Z"} -> "Z"
      {"C", "Z"} -> "X"
    end
  end

  def exec do
    {:ok, contents} = File.read("day2.txt")

    contents
    |> String.split("\n")
    |> Enum.map(fn x -> scoreRoundPartTwo x end)
    |> Enum.sum
  end
end

Day2.exec

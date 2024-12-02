defmodule Day2 do
  @symbols ["A", "B", "C"]
  @win_lose ["X", "Y", "Z"]

  def scoreRound(line) do
    with [theirs, winLoseDraw] <- line |> String.split(" ") do
      theirIndex = Enum.find_index(@symbols, fn x -> x == theirs end)
      inc = Enum.find_index(@win_lose, fn x -> x == winLoseDraw end) + 2
      myIndex = theirIndex + inc
      myVal = rem(myIndex, 2)

      IO.inspect {line, myVal}

      cond do
        theirIndex == rem(myIndex, 3) -> 3 + myVal
        theirIndex > rem(myIndex, 3) -> 0 + myVal
        theirIndex < rem(myIndex, 3) -> 6 + myVal
      end
    else
      _ -> 0
    end
  end

  def exec do
    {:ok, contents} = File.read("day2.txt")

    contents
    |> String.split("\n")
    |> Enum.map(fn x -> scoreRound x end)
  end
end

Day2.exec

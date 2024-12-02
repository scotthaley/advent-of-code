defmodule Day5 do
  def parseStart(start) do
    start
    |> Enum.take(Enum.count(start) - 1)
    |> Enum.map(fn x -> x |> String.split("", trim: true) end)
    |> Enum.map(fn x -> x |> Enum.chunk_every(4) end)
    |> Enum.map(fn x -> x |> Enum.map(fn y -> y |> Enum.at(1) end) end)
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(fn x -> x |> Enum.filter(fn y -> y != " " end) end)
  end

  def applyProc(state, proc) do
    regex = ~r/move (?<count>\d+) from (?<start>\d+) to (?<dest>\d+)/
    captures = Regex.named_captures(regex, proc)
    %{"count" => count, "start" => start, "dest" => dest} = captures

    {count, _ } = Integer.parse(count)
    {start, _ } = Integer.parse(start)
    {dest, _ } = Integer.parse(dest)

    applyProc9001(state, start - 1, dest - 1, count)
  end

  def applyProc(state, _, _, count) when count == 0 do
    state
  end

  def applyProc(state, start, dest, count) when count != 0 do
    crate = Enum.at(state, start)
    |> Enum.at(0)

    newState = state
    |> Enum.with_index
    |> Enum.map(fn
      {v, ^start} -> Enum.drop(v, 1)
      {v, ^dest} -> [crate | v]
      {v, _} -> v
    end)

    applyProc(newState, start, dest, count - 1)
  end

  def applyProc9001(state, start, dest, count) do
    crates = Enum.at(state, start)
    |> Enum.slice(0, count)

    state
    |> Enum.with_index
    |> Enum.map(fn
      {v, ^start} -> Enum.drop(v, count)
      {v, ^dest} -> Enum.concat(crates, v)
      {v, _} -> v
    end)
  end

  def applyProcs(state, procs) do
    applyProcs(state, procs, 0, Enum.count(procs))
  end

  def applyProcs(state, _, i, count) when i == count do
    state
  end

  def applyProcs(state, procs, i, count) when i != count do
    newState = applyProc(state, Enum.at(procs, i))

    applyProcs(newState, procs, i + 1, count)
  end

  def exec do
    {:ok, contents} = File.read("day5.txt")

    {state, procs} = contents
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn x -> x |> String.split("\n", trim: true) end)
    |> then(fn [start, procs] -> {start, procs} end)
    |> then(fn {start, procs} -> {parseStart(start), procs} end)

    applyProcs(state, procs)
    |> Enum.map(fn x -> Enum.at(x, 0) end)
    |> Enum.join
  end
end

Day5.exec

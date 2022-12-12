defmodule Day10 do
  def createOp(op) do
    createOp(op, nil)
  end

  def createOp(op, val) do
    {op, val}
  end

  def expandCommand(cmd) do
    parts = cmd |> String.split(" ", trim: true)
    case parts do
      ["noop"] -> [createOp("noop")]
      ["addx", num] ->
        {n, _} = Integer.parse(num)
        [
          createOp("adda"),
          createOp("addx", n)
        ]
    end
  end

  def runOp({x, cycle, next}, {op, val}) do
    case op do
      "addx" -> {x, cycle + 1, x + val}
      _ -> {next || x, cycle + 1, nil}
    end
  end

  def exec do
    {:ok, contents} = File.read("day10.txt")

    start = {1, 0, nil}

    contents
    |> String.split("\n", trim: true)
    |> Enum.reduce([], fn cur, acc ->
      acc ++ expandCommand(cur)
    end)
    |> Enum.reduce([start], fn cur, [head | _] = acc ->
      s = runOp(head, cur)
      [s | acc]
    end)
    |> Enum.reverse
    |> Enum.map(fn {x, _, next} -> next || x end)
    |> Enum.with_index
    |> Enum.each(fn {x, i} ->
      mod = Integer.mod(i, 40)
      p = cond do
        mod == x-> "#"
        mod == x - 1 -> "#"
        mod == x + 1 -> "#"
        true -> "."
      end

      if mod == 0 and i != 0 do
        IO.write("\n")
      end

      IO.write(p)
    end)


    # Part 1
    # |> Enum.reduce([], fn {x, cycle, _}, list ->
    #   cond do
    #     cycle == 20 -> [{x, cycle} | list]
    #     Integer.mod(cycle - 20, 40) == 0 -> [{x, cycle} | list]
    #     true -> list
    #   end
    # end)
    # |> Enum.map(fn {x, cycle} -> x * cycle end)
    # |> Enum.sum
  end
end

Day10.exec

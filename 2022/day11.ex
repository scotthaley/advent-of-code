defmodule Day11 do
  def parseIndex(input) do
    [_, index] = Regex.run(~r/Monkey (\d):/, input)
    {index, _} = Integer.parse(index)
    index
  end

  def parseStartingItems(input) do
    [_, items] = Regex.run(~r/Starting items: ([\d, ]*)/, input)

    items
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&Integer.parse(&1))
    |> Enum.map(fn {item, _} -> item end)
  end

  def parseOperation(input) do
    [_, op, right] = Regex.run(~r/Operation: new = old ([\*\+]) (\w+)/, input)

    right =
      case right do
        "old" ->
          "old"

        _ ->
          {num, _} = Integer.parse(right)
          num
      end

    case {op, right} do
      {"*", "old"} -> fn x -> x * x end
      {"+", "old"} -> fn x -> x + x end
      {"*", _} -> fn x -> x * right end
      {"+", _} -> fn x -> x + right end
    end
  end

  def parseTest([input1, input2, input3]) do
    [_, divisor] = Regex.run(~r/Test: divisible by (\d+)/, input1)
    {divisor, _} = Integer.parse(divisor)
    [_, throwTrue] = Regex.run(~r/If true: throw to monkey (\d+)/, input2)
    {throwTrue, _} = Integer.parse(throwTrue)
    [_, throwFalse] = Regex.run(~r/If false: throw to monkey (\d+)/, input3)
    {throwFalse, _} = Integer.parse(throwFalse)

    {divisor,
     fn x ->
       case Integer.mod(x, divisor) do
         0 -> {true, throwTrue}
         _ -> {false, throwFalse}
       end
     end}
  end

  def parseMonkey(notes) do
    parts =
      notes
      |> String.split("\n", trim: true)

    index = parseIndex(Enum.at(parts, 0))
    items = parseStartingItems(Enum.at(parts, 1))
    operation = parseOperation(Enum.at(parts, 2))
    {divisor, test} = parseTest(Enum.slice(parts, 3..5))

    %{i: index, items: items, operation: operation, test: test, divisor: divisor, inspected: 0}
  end

  def gcd(a, 0), do: a
	def gcd(0, b), do: b
	def gcd(a, b), do: gcd(b, rem(a,b))

	def lcm(0, 0), do: 0
	def lcm(a, b), do: floor((a*b)/gcd(a,b))

  def monkeyInspect(index, monkeys, round, mod) do
    m = monkeys[index]
    items = m[:items]

    # IO.write("Monkey " <> to_string(index) <> ":\n")

    if Enum.count(items) > 0 do
        0..(Enum.count(items) - 1)
        |> Enum.reduce(monkeys, fn i, acc ->
          item = Enum.at(items, i)
          divisor = m[:divisor]
          newLevel = m[:operation].(item)
          # endLevel = floor(newLevel / 3)
          endLevel = newLevel
          {divisible?, throwTo} = m[:test].(newLevel)

          # IO.inspect {
          #   itemOld,
          #   item,
          #   {
          #     Integer.mod(m[:operation].(itemOld), m[:divisor]),
          #     Integer.mod(m[:operation].(item), m[:divisor]),
          #   },
          #   {
          #     throwTo,
          #     throwToOld
          #   }
          # }

          # IO.write("  Monkey inspects an item with a worry level of " <> to_string(item) <> "\n")
          # IO.write("    Worry level is now: " <> to_string(newLevel) <> "\n")
          # IO.write("    Monkey gets bored. Level is now " <> to_string(endLevel) <> "\n")
          # IO.write("    Current worry level is ")

          # unless divisible? do
          #   IO.write("not ")
          # end

          # IO.write("divisible by " <> to_string(m[:divisor]) <> "\n")

          # IO.write(
          #   "    Item with worry level " <>
          #     to_string(endLevel) <> " is thrown to monkey " <> to_string(throwTo) <> "\n"
          # )

          [_ | newItems] = acc[index][:items]
          acc = put_in(acc, [index, :items], newItems)
          acc = update_in(acc, [index, :inspected], fn x -> x + 1 end)

          adjusted = Integer.mod(endLevel, mod)

          newOtherItems = acc[throwTo][:items] ++ [adjusted]
          put_in(acc, [throwTo, :items], newOtherItems)
        end)
    else
      monkeys
    end
  end

  def execRound(monkeys, round, mod) do
    0..(Enum.count(monkeys) - 1)
    |> Enum.reduce(monkeys, fn i, acc -> monkeyInspect(i, acc, round, mod) end)
  end

  def exec(input) do
    monkeys =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(&parseMonkey(&1))
      |> Enum.group_by(fn x -> x[:i] end)
      |> Enum.map(fn {k, [v]} -> {k, v} end)
      |> Enum.into(%{})

    mod =
      monkeys
        |> Enum.map(fn {_, v} -> v[:divisor] end)
        |> Enum.product


    0..9999
    |> Enum.reduce(monkeys, fn round, acc -> execRound(acc, round, mod) end)
    |> Enum.map(fn {_, v} -> v[:inspected] end)
    |> IO.inspect(charlists: :as_lists)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.slice(0..1)
    |> Enum.product()
  end
end

Day11.exec(body)

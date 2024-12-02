defmodule Day8 do

  def countVisible(grid, rowIndex) do
    row = Enum.at(grid, rowIndex)
    rowMax = Enum.count(row) - 1
    colMax = Enum.count(grid) - 1

    0..(Enum.count(row) - 1)
    |> Enum.map(fn x -> isVisible(grid, rowIndex, x, rowMax, colMax) end)
    |> Enum.filter(fn x -> x end)
    |> Enum.count
  end

  def isVisible(_, rowIndex, colIndex, rowMax, colMax) when rowIndex == 0 or colIndex == 0 or rowIndex == rowMax or colIndex == colMax do
    true
  end

  def isVisible(grid, rowIndex, colIndex, rowMax, colMax) do
    row = Enum.at(grid, rowIndex)
    tree = Enum.at(row, colIndex)

    leftRow = 0..(colIndex - 1)
    rightRow = (colIndex + 1)..rowMax
    topCol = 0..(rowIndex - 1)
    botCol = (rowIndex + 1)..colMax

    left = Enum.any?(leftRow, fn x -> Enum.at(row, x) >= tree end)
    right = Enum.any?(rightRow, fn x -> Enum.at(row, x) >= tree end)
    top = Enum.any?(topCol, fn x -> Enum.at(Enum.at(grid, x), colIndex) >= tree end)
    bot = Enum.any?(botCol, fn x -> Enum.at(Enum.at(grid, x), colIndex) >= tree end)

    not (left and right and top and bot)
  end

  def getMaxScenicScore(grid) do
    0..(Enum.count(grid) - 1)
    |> Enum.map(fn x ->
      0..(Enum.count(Enum.at(grid, x)) - 1)
      |> Enum.map(fn y -> getScenicScore(grid, x, y) end)
    end)
    |> Enum.map(fn x -> Enum.max(x) end)
    |> Enum.max
  end

  def getScenicScore(grid, rowIndex, colIndex) do
    row = Enum.at(grid, rowIndex)
    tree = Enum.at(row, colIndex)

    rowMax = Enum.count(row) - 1
    colMax = Enum.count(grid) - 1

    leftRow = max(colIndex - 1, 0)..0
    rightRow = min(colIndex + 1, rowMax)..rowMax
    topCol = max(rowIndex - 1, 0)..0
    botCol = min(rowIndex + 1, colMax)..colMax

    left = Enum.find(leftRow, fn x -> Enum.at(row, x) >= tree end)
    right = Enum.find(rightRow, fn x -> Enum.at(row, x) >= tree end)
    top = Enum.find(topCol, fn x -> Enum.at(Enum.at(grid, x), colIndex) >= tree end)
    bot = Enum.find(botCol, fn x -> Enum.at(Enum.at(grid, x), colIndex) >= tree end)

    leftCount = case left do
                  nil -> colIndex
                  num -> colIndex - num
                end
    rightCount = case right do
                   nil -> colMax - colIndex
                   num -> num - colIndex
                 end
    topCount = case top do
                 nil -> rowIndex
                 num -> rowIndex - num
               end
    botCount = case bot do
                 nil -> rowMax - rowIndex
                 num -> num - rowIndex
               end

    leftCount * rightCount * topCount * botCount
  end


  def exec do
    {:ok, contents} = File.read("day8.txt")

    grid = contents
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> String.split(x, "", trim: true) end)
    |> Enum.map(fn x -> Enum.map(x, fn y -> Integer.parse(y) end) end)
    |> Enum.map(fn x -> Enum.map(x, fn {num, _} -> num end) end)

    0..(Enum.count(grid) - 1)
    |> Enum.map(fn x -> countVisible(grid, x) end)
    |> Enum.sum
  end

  def exec2 do
    {:ok, contents} = File.read("day8.txt")

    grid = contents
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> String.split(x, "", trim: true) end)
    |> Enum.map(fn x -> Enum.map(x, fn y -> Integer.parse(y) end) end)
    |> Enum.map(fn x -> Enum.map(x, fn {num, _} -> num end) end)

    getMaxScenicScore(grid)
  end
end

Day8.exec2

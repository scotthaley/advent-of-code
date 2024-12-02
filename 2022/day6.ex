defmodule Day6 do
  @message_size 14

  def find_marker(list) do
    find_marker(list, @message_size)
  end

  def find_marker(list, index) do
    cond do
      is_marker(list, index) -> index
      true -> find_marker(list, index + 1)
    end
  end

  def is_marker(list, index) do
    count = Enum.slice(list, index - @message_size, @message_size)
    |> Enum.uniq
    |> Enum.count

    count == @message_size
  end

  def exec do
    {:ok, contents} = File.read("day6.txt")

    contents
    |> String.split("", trim: true)
    |> find_marker
  end
end

Day6.exec

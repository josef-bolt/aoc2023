defmodule TwentyThree.Four do
  @moduledoc """
  https://adventofcode.com/2023/day/4
  """

  @example """
  Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
  Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
  Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
  Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
  Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
  """

  def input do
    File.read!("priv/day4.txt")
  end

  def parse(input \\ @example) do
    parse_line = fn line ->
      ["Card " <> card_num_str, winning_num_str, owned_num_str] = String.split(line, [":", "|"])

      winning_nums =
        winning_num_str
        |> String.split()
        |> Enum.map(&String.to_integer/1)

      owned_nums =
        owned_num_str
        |> String.split()
        |> Enum.map(&String.to_integer/1)

      %{
        number: card_num_str |> String.trim() |> String.to_integer(),
        winning: MapSet.new(winning_nums),
        owned: owned_nums
      }
    end

    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(parse_line)
  end

  # 26346
  def first(input \\ @example) do
    input
    |> parse()
    |> Enum.map(&score_line/1)
    |> Enum.sum()
  end

  defp score_line(%{owned: owned, winning: winning}) do
    count = Enum.count(owned, &MapSet.member?(winning, &1))

    if count == 0, do: 0, else: 2 ** (count - 1)
  end

  # 8467762
  def second(input \\ @example) do
    cards = parse(input)

    cards_map =
      cards
      |> Enum.map(fn card ->
        card_data =
          card
          |> Map.delete(:number)
          |> Map.put(:count, 1)

        {card.number, card_data}
      end)
      |> Map.new()

    cards
    |> Enum.reduce(cards_map, fn card, acc ->
      num_matching = Enum.count(card.owned, &Enum.member?(card.winning, &1))

      if num_matching > 0 do
        Enum.reduce((card.number + 1)..(card.number + num_matching), acc, fn ind, acc ->
          {_, new_acc} = get_and_update_in(acc[ind][:count], &{&1, &1 + acc[card.number].count})
          new_acc
        end)
      else
        acc
      end
    end)
    |> Enum.map(fn {_num, card} -> card.count end)
    |> Enum.sum()
  end
end

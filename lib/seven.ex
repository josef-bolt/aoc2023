defmodule TwentyThree.Seven do
  @moduledoc """
  https://adventofcode.com/2023/day/7
  """

  @example """
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
  """

  @hand_str [:quints, :quads, :full_house, :trips, :two_pair, :pair, :high]
  @card_str ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]
  @pt2_card_str ["A", "K", "Q", "T", "9", "8", "7", "6", "5", "4", "3", "2", "J"]

  def input do
    File.read!("priv/day7.txt")
  end

  def parse(input \\ @example) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line)
      %{hand: String.codepoints(hand), bid: String.to_integer(bid)}
    end)
  end

  # 256448566
  def first(input \\ @example) do
    input
    |> parse()
    |> Enum.map(&Map.put(&1, :type, hand_type(&1.hand)))
    |> Enum.sort(&hand_sorter/2)
    |> Enum.with_index(1)
    |> Enum.map(fn {hand, rank} -> rank * hand.bid end)
    |> Enum.sum()
  end

  # 254412181
  def second(input \\ @example) do
    input
    |> parse()
    |> Enum.map(fn %{hand: hand} = line ->
      init_type = hand |> Enum.reject(&(&1 == "J")) |> hand_type()
      actual_type = promote(hand, init_type)

      Map.put(line, :type, actual_type)
    end)
    |> Enum.sort(&hand_sorter(&1, &2, @pt2_card_str))
    |> Enum.with_index(1)
    |> Enum.map(fn {hand, rank} -> rank * hand.bid end)
    |> Enum.sum()
  end

  defp promote(hand, type) do
    num_wilds = Enum.count(hand, &(&1 == "J"))

    case type do
      :quints ->
        :quints

      :quads ->
        if num_wilds == 1, do: :quints, else: :quads

      :full_house ->
        :full_house

      :trips ->
        case num_wilds do
          2 -> :quints
          1 -> :quads
          0 -> :trips
        end

      :two_pair ->
        case num_wilds do
          1 -> :full_house
          0 -> :two_pair
        end

      :pair ->
        case num_wilds do
          3 -> :quints
          2 -> :quads
          1 -> :trips
          0 -> :pair
        end

      :high ->
        case num_wilds do
          5 -> :quints
          4 -> :quints
          3 -> :quads
          2 -> :trips
          1 -> :pair
          0 -> :high
        end
    end
  end

  defp hand_sorter(h1, h2, card_ordering \\ @card_str) do
    h1_hand_str = Enum.find_index(@hand_str, &(&1 == h1.type))
    h2_hand_str = Enum.find_index(@hand_str, &(&1 == h2.type))

    cond do
      h1_hand_str < h2_hand_str ->
        false

      h2_hand_str < h1_hand_str ->
        true

      true ->
        {c, d} =
          [h1.hand, h2.hand]
          |> Enum.zip()
          |> Enum.find(fn {c, d} -> c != d end)

        c_str = Enum.find_index(card_ordering, &(&1 == c))
        d_str = Enum.find_index(card_ordering, &(&1 == d))

        if c_str < d_str, do: false, else: true
    end
  end

  defp hand_type(hand) do
    cond do
      quints?(hand) -> :quints
      quads?(hand) -> :quads
      full_house?(hand) -> :full_house
      trips?(hand) -> :trips
      two_pair?(hand) -> :two_pair
      pair?(hand) -> :pair
      true -> :high
    end
  end

  defp quints?(hand) do
    hand
    |> Enum.frequencies()
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.sort()
    |> case do
      [5] -> true
      _ -> false
    end
  end

  defp quads?(hand) do
    freq =
      hand
      |> Enum.frequencies()
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.sort()

    Enum.member?(freq, 4)
  end

  defp full_house?(hand) do
    hand
    |> Enum.frequencies()
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.sort()
    |> case do
      [2, 3] -> true
      _ -> false
    end
  end

  defp trips?(hand) do
    freq =
      hand
      |> Enum.frequencies()
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.sort()

    Enum.member?(freq, 3)
  end

  defp two_pair?(hand) do
    hand
    |> Enum.frequencies()
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.sort()
    |> Enum.filter(&(&1 == 2))
    |> case do
      [_, _] -> true
      _ -> false
    end
  end

  defp pair?(hand) do
    hand
    |> Enum.frequencies()
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.sort()
    |> Enum.filter(&(&1 == 2))
    |> case do
      [_] -> true
      _ -> false
    end
  end
end

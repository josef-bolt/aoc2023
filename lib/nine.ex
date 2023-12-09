defmodule TwentyThree.Nine do
  @moduledoc """
  https://adventofcode.com/2023/day/9
  """

  @example """
  0 3 6 9 12 15
  1 3 6 10 15 21
  10 13 16 21 30 45
  """

  def input do
    File.read!("priv/day9.txt")
  end

  def parse(input \\ @example) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  # 2075724761
  def first(input \\ @example) do
    input
    |> parse()
    |> Enum.map(&next_in_sequence/1)
    |> Enum.sum()
  end

  defp next_in_sequence(sequence, acc \\ []) do
    d_seq = d_seq(sequence)

    if Enum.all?(d_seq, & &1 == 0) do
      Enum.sum(acc) + List.last(sequence)
    else
      next_in_sequence(d_seq, [List.last(sequence) | acc])
    end
  end

  # 1072
  def second(input \\ @example) do
    input
    |> parse()
    |> Enum.map(&prev_in_seq/1)
    |> Enum.sum()
  end

  defp prev_in_seq([h | _] = sequence, acc \\ []) do
    d_seq = d_seq(sequence)

    if Enum.all?(d_seq, & &1 == 0) do
      [h | acc]
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.reduce(0, fn {val, ind}, acc ->
        cond do
          rem(ind, 2) == 0 -> acc + val
          true -> acc - val
        end
      end)
    else
      prev_in_seq(d_seq, [h | acc])
    end
  end

  defp d_seq(seq) do
    seq
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce([], fn [a, b], acc ->
      [b - a | acc]
    end)
    |> Enum.reverse()
  end
end

defmodule TwentyThree.Six do
  @moduledoc """
  https://adventofcode.com/2023/day/6
  """

  @example """
  Time:      7  15   30
  Distance:  9  40  200
  """

  def input do
    File.read!("priv/day6.txt")
  end

  def parse(input \\ @example) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [_ | nums] -> Enum.map(nums, &String.to_integer/1) end)
    |> Enum.zip_with(fn [time, distance] -> %{time: time, distance: distance} end)
  end

  # 4811940
  def first(input \\ @example) do
    input
    |> parse()
    |> Enum.map(&num_options/1)
    |> Enum.product()
  end

  defp num_options(%{time: time, distance: distance}) do
    Enum.count(1..(time - 1), fn t ->
      t * (time - t) > distance
    end)
  end

  def parse_second(input \\ @example) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [_ | nums] ->
      nums
      |> Enum.join()
      |> String.to_integer()
    end)
    |> then(fn [t, d] -> %{time: t, distance: d} end)
  end

  # 30077773
  def second(input \\ @example) do
    %{distance: distance, time: time} = parse_second(input)

    first_soln = (time + :math.sqrt(time ** 2 - 4 * distance)) / 2
    second_soln = (time - :math.sqrt(time ** 2 - 4 * distance)) / 2

    ceil(first_soln) - ceil(second_soln)
  end
end

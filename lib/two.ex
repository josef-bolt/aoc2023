defmodule TwentyThree.Two do
  @moduledoc """
  https://adventofcode.com/2023/day/2
  """

  @example """
  Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
  Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
  Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
  Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
  """

  def input do
    File.read!("priv/day2.txt")
  end

  def parse(input \\ @example) do
    parse_ball_info = fn info ->
      [num, color] = String.split(info, " ")
      {color, String.to_integer(num)}
    end

    parse_round = fn round ->
      round
      |> String.trim()
      |> String.split(", ")
      |> Enum.map(parse_ball_info)
      |> Map.new()
    end

    parse_line = fn line ->
      ["Game " <> id, rest] = String.split(line, ":")

      rest
      |> String.split("; ")
      |> Enum.map(parse_round)
      |> then(&{String.to_integer(id), &1})
    end

    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(parse_line)
  end

  # 2149
  def first(input \\ @example) do
    limits = %{"red" => 12, "green" => 13, "blue" => 14}

    round_possible? = fn {_id, draws} ->
      Enum.all?(draws, fn draw ->
        Map.get(draw, "red", 0) <= limits["red"] and
          Map.get(draw, "green", 0) <= limits["green"] and
          Map.get(draw, "blue", 0) <= limits["blue"]
      end)
    end

    input
    |> parse()
    |> Enum.reduce(0, fn {id, _draws} = round, acc ->
      if round_possible?.(round), do: acc + id, else: acc
    end)
  end

  # 71274
  def second(input \\ @example) do
    input
    |> parse()
    |> Enum.reduce(0, fn {_id, draws}, acc ->
      min_red = draws |> Enum.max_by(fn draw -> Map.get(draw, "red", 0) end) |> Map.get("red", 0)

      min_green =
        draws |> Enum.max_by(fn draw -> Map.get(draw, "green", 0) end) |> Map.get("green", 0)

      min_blue =
        draws |> Enum.max_by(fn draw -> Map.get(draw, "blue", 0) end) |> Map.get("blue", 0)

      acc + min_red * min_green * min_blue
    end)
  end
end

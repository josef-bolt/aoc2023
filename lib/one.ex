defmodule TwentyThree.One do
  @moduledoc """
  https://adventofcode.com/2023/day/1
  """

  @example """
  1abc2
  pqr3stu8vwx
  a1b2c3d4e5f
  treb7uchet
  """

  def input do
    File.read!("priv/day1.txt")
  end

  def parse(input \\ @example) do
    input
    |> String.trim()
    |> String.split("\n")
  end

  # 54304
  def first(input \\ @example) do
    input
    |> parse()
    |> Enum.map(&String.codepoints/1)
    |> Enum.map(fn line ->
      [first_num | _] =
        nums =
        Enum.filter(line, fn char ->
          case Integer.parse(char) do
            {_num, _extra} -> true
            :error -> false
          end
        end)

      last_num = List.last(nums)

      {num, _} = Integer.parse("#{first_num}#{last_num}")
      num
    end)
    |> Enum.sum()
  end

  @second_example """
  two1nine
  eightwothree
  abcone2threexyz
  xtwone3four
  4nineeightseven2
  zoneight234
  7pqrstsixteen
  """

  # 54418
  def second(input \\ @second_example) do
    number_words = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

    number_mapping =
      number_words
      |> Enum.zip(Enum.map(1..9, &Integer.to_string/1))
      |> Map.new()

    numbers = number_words ++ Enum.map(0..9, &Integer.to_string/1)

    {:ok, regex} =
      numbers
      |> Enum.join("|")
      |> Regex.compile()

    reverse_number_words = Enum.map(number_words, &String.reverse/1)

    reverse_number_mapping =
      reverse_number_words
      |> Enum.zip(Enum.map(1..9, &Integer.to_string/1))
      |> Map.new()

    reverse_numbers = reverse_number_words ++ Enum.map(0..9, &Integer.to_string/1)

    {:ok, reverse_regex} =
      reverse_numbers
      |> Enum.join("|")
      |> Regex.compile()

    parsed_input = parse(input)

    first_digits =
      parsed_input
      |> Enum.map(fn line ->
        line
        |> String.split(regex, include_captures: true)
        |> Enum.filter(&Enum.member?(numbers, &1))
        |> then(&List.first(&1))
        |> then(fn num ->
          case Integer.parse(num) do
            {_, _} -> num
            :error -> Map.fetch!(number_mapping, num)
          end
        end)
      end)

    last_digits =
      parsed_input
      |> Enum.map(&String.reverse/1)
      |> Enum.map(fn line ->
        line
        |> String.split(reverse_regex, include_captures: true)
        |> Enum.filter(&Enum.member?(reverse_numbers, &1))
        |> then(&List.first(&1))
        |> then(fn num ->
          case num |> String.reverse() |> Integer.parse() do
            {_, _} -> num
            :error -> Map.fetch!(reverse_number_mapping, num)
          end
        end)
      end)

    first_digits
    |> Enum.zip(last_digits)
    |> Enum.map(fn {x, y} ->
      {num, _} = Integer.parse("#{x}#{y}")
      num
    end)
    |> Enum.sum()
  end
end

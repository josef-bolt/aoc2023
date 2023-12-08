defmodule TwentyThree.Eight do
  @moduledoc """
  https://adventofcode.com/2023/day/8
  """

  @example """
  LLR

  AAA = (BBB, BBB)
  BBB = (AAA, ZZZ)
  ZZZ = (ZZZ, ZZZ)
  """

  def input do
    File.read!("priv/day8.txt")
  end

  def parse(input \\ @example) do
    [ins, _ | locs] =
      input
      |> String.trim()
      |> String.split("\n")

    parse_loc = fn loc ->
      [src, "=", l, r] = loc |> String.replace(["(", ")", ","], "") |> String.split()
      {src, {l, r}}
    end

    %{
      ins: String.codepoints(ins),
      locs: locs |> Enum.map(parse_loc) |> Map.new()
    }
  end

  # 14893
  def first(input \\ @example) do
    %{ins: ins, locs: locs} = parse(input)
    step("AAA", locs, 0, ins)
  end

  defp step(current_loc, locs, current_ins_ind, ins, acc \\ 0) do
    case current_loc do
      "ZZZ" ->
        acc

      loc ->
        next_loc =
          case Enum.at(ins, current_ins_ind) do
            "L" -> elem(locs[loc], 0)
            "R" -> elem(locs[loc], 1)
          end

        next_ins_index =
          cond do
            current_ins_ind + 1 == Enum.count(ins) -> 0
            true -> current_ins_ind + 1
          end

        step(next_loc, locs, next_ins_index, ins, acc + 1)
    end
  end

  @second_example """
  LR

  11A = (11B, XXX)
  11B = (XXX, 11Z)
  11Z = (11B, XXX)
  22A = (22B, XXX)
  22B = (22C, 22C)
  22C = (22Z, 22Z)
  22Z = (22B, 22B)
  XXX = (XXX, XXX)
  """

  # 10241191004509
  def second(input \\ @second_example) do
    %{ins: ins, locs: locs} = parse(input)

    locs
    |> Enum.map(fn {key, _val} -> key end)
    |> Enum.filter(&String.ends_with?(&1, "A"))
    |> Enum.map(&step2(&1, locs, 0, ins))
    |> Enum.reduce(fn val, acc ->
      div(val * acc, Integer.gcd(val, acc))
    end)
  end

  defp step2(current_loc, locs, current_ins_ind, ins, acc \\ 0) do
    if String.ends_with?(current_loc, "Z") do
      acc
    else
      next_loc =
        case Enum.at(ins, current_ins_ind) do
          "L" -> elem(locs[current_loc], 0)
          "R" -> elem(locs[current_loc], 1)
        end

      next_ins_index =
        cond do
          current_ins_ind + 1 == Enum.count(ins) -> 0
          true -> current_ins_ind + 1
        end

      step2(next_loc, locs, next_ins_index, ins, acc + 1)
    end
  end
end

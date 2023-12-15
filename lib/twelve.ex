defmodule TwentyThree.Twelve do
  @moduledoc """
  https://adventofcode.com/2023/day/12
  """

  @example """
  ???.### 1,1,3
  .??..??...?##. 1,1,3
  ?#?#?#?#?#?#?#? 1,3,1,6
  ????.#...#... 4,1,1
  ????.######..#####. 1,6,5
  ?###???????? 3,2,1
  """

  def input do
    File.read!("priv/day12.txt")
  end

  def parse(input \\ @example) do
    parse_line = fn line ->
      [pattern, counts] = String.split(line, " ")

      %{
        pattern: pattern |> String.codepoints() |> Enum.reverse(),
        counts: counts |> String.split(",") |> Enum.map(&String.to_integer/1) |> Enum.reverse()
      }
    end

    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(parse_line)
  end

  # 7705
  def first(input \\ @example) do
    input
    |> parse()
    |> Enum.map(&solve_line(&1, 0))
    |> Enum.sum()
  end

  def second(input \\ @example) do
    input
    |> parse()
    |> tap(fn lines -> IO.inspect("Total: #{Enum.count(lines)}") end)
    |> Enum.map(fn %{pattern: pattern, counts: counts} ->
      %{
        pattern: pattern |> List.duplicate(5) |> Enum.join("?") |> String.codepoints(),
        counts: counts |> List.duplicate(5) |> List.flatten()
      }
    end)
    |> Enum.with_index()
    |> Enum.map(fn {line, ind} ->
      IO.inspect("Line #{ind}")
      IO.inspect(line)
      solve_line(line, 0)
    end)
    |> Enum.sum()
  end

  defp solve_line(%{counts: [], pattern: []}, _acc), do: 1

  defp solve_line(%{counts: [], pattern: p}, _acc), do: if("#" in p, do: 0, else: 1)

  defp solve_line(%{counts: [h | t] = counts, pattern: pattern}, acc) do
    case pattern do
      [] ->
        0

      ["." | rest] ->
        solve_line(%{counts: counts, pattern: rest}, acc)

      ["?" | rest] ->
        solve_line(%{counts: counts, pattern: rest}, acc) +
          solve_line(%{counts: counts, pattern: ["#" | rest]}, acc)

      ["#" | _rest] ->
        {prefix, leftover} = Enum.split(pattern, h)

        cond do
          List.first(leftover) == "#" ->
            0

          "." in prefix ->
            0

          Enum.count(prefix) < h ->
            0

          true ->
            case leftover do
              [_ | y] -> solve_line(%{counts: t, pattern: y}, acc)
              _ -> solve_line(%{counts: t, pattern: leftover}, acc)
            end
        end
    end
  end
end

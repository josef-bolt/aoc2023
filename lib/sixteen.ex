defmodule TwentyThree.Sixteen do
  @moduledoc """
  https://adventofcode.com/2023/day/16
  """

  #  0123456789
  # 0 .|...\....
  # 1 |.-.\.....
  # 2 .....|-...
  # 3 ........|.
  # 4 ..........
  # 5 .........\
  # 6 ..../.\\..
  # 7 .-.-/..|..
  # 8 .|....-|.\
  # 9 ..//.|....

  @example File.read!("priv/day16example.txt")

  def input do
    File.read!("priv/day16.txt")
  end

  def parse(input \\ @example) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
  end

  # 6795
  def first(input \\ @example) do
    parsed_input = parse(input)

    grid =
      parsed_input
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, i} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {cell, j} ->
          {{i, j}, cell}
        end)
      end)
      |> Map.new()

    step(
      [{{0, 0}, {0, 1}}],
      grid,
      [],
      {0..(Enum.count(parsed_input) - 1), 0..(Enum.count(hd(parsed_input)) - 1)},
      0
    )
    |> Enum.map(fn {p, _} -> p end)
    |> Enum.uniq()
    |> Enum.count()
  end

  # 7154
  def second(input \\ @example) do
    parsed_input = parse(input)

    grid =
      parsed_input
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, i} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {cell, j} ->
          {{i, j}, cell}
        end)
      end)
      |> Map.new()

    row_range = 0..(Enum.count(parsed_input) - 1)
    col_range = 0..(Enum.count(hd(parsed_input)) - 1)

    top_starts = for r <- row_range, do: {{r, 0}, {0, 1}}
    bottom_starts = for r <- row_range, do: {{r, col_range.last}, {0, -1}}
    left_starts = for c <- col_range, do: {{0, c}, {1, 0}}
    right_starts = for c <- col_range, do: {{row_range.last, c}, {-1, 0}}

    starts = Enum.concat([top_starts, bottom_starts, left_starts, right_starts])

    starts
    |> Enum.with_index()
    |> Enum.map(fn {start, index} ->
      IO.inspect(index)

      step(
        [start],
        grid,
        [],
        {0..(Enum.count(parsed_input) - 1), 0..(Enum.count(hd(parsed_input)) - 1)},
        0
      )
      |> Enum.map(fn {p, _} -> p end)
      |> Enum.uniq()
      |> Enum.count()
    end)
    |> Enum.max()
  end

  defp step(current_positions, grid, visited_positions, {row_range, col_range} = range, count) do
    current_positions =
      Enum.filter(current_positions, fn {{r, c}, _d} = pos ->
        pos not in visited_positions and r in row_range and c in col_range
      end)

    visited_positions = current_positions ++ visited_positions

    case current_positions do
      [] ->
        visited_positions

      _ ->
        current_positions
        |> Enum.flat_map(&process_position(&1, grid))
        |> Enum.uniq()
        |> step(grid, visited_positions, range, count + 1)
    end
  end

  defp process_position({{row, col} = pos, {dr, dc} = dir}, grid) do
    case Map.get(grid, pos) do
      "-" when dir in [{1, 0}, {-1, 0}] ->
        [{{row, col + 1}, {0, 1}}, {{row, col - 1}, {0, -1}}]

      "|" when dir in [{0, 1}, {0, -1}] ->
        [{{row + 1, col}, {1, 0}}, {{row - 1, col}, {-1, 0}}]

      "/" ->
        {new_dr, new_dc} = {dc * -1, dr * -1}
        [{{row + new_dr, col + new_dc}, {new_dr, new_dc}}]

      "\\" ->
        {new_dr, new_dc} = {dc, dr}
        [{{row + new_dr, col + new_dc}, {new_dr, new_dc}}]

      _ ->
        [{{row + dr, col + dc}, dir}]
    end
  end
end

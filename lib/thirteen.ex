defmodule TwentyThree.Thirteen do
  @moduledoc """
  https://adventofcode.com/2023/day/13
  """

  @example """
  #.##..##.
  ..#.##.#.
  ##......#
  ##......#
  ..#.##.#.
  ..##..##.
  #.#.##.#.

  #...##..#
  #....#..#
  ..##..###
  #####.##.
  #####.##.
  ..##..###
  #....#..#
  """

  def input do
    File.read!("priv/day13.txt")
  end

  def parse(input \\ @example) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
    |> Enum.chunk_by(&(&1 == []))
    |> Enum.reject(&(&1 == [[]]))
  end

  # 35360
  def first(input \\ @example) do
    input
    |> parse()
    |> Enum.map(&find_reflection/1)
    |> Enum.sum()
  end

  defp find_reflection([h | _t] = grid) do
    grid_cols = Enum.count(h)

    v_refl = fn grid, grid_cols ->
      Enum.find_index(0..(grid_cols - 2), fn ind ->
        refl_range = Enum.min([ind, grid_cols - ind - 2])

        lhs = Enum.map(grid, &Enum.slice(&1, (ind - refl_range)..ind))

        rhs =
          grid
          |> Enum.map(&Enum.slice(&1, (ind + 1)..(ind + 1 + refl_range)))
          |> Enum.map(&Enum.reverse/1)

        lhs == rhs
      end)
    end

    refl = v_refl.(grid, grid_cols)

    if refl do
      refl + 1
    else
      grid_rows = Enum.count(grid)

      grid
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> v_refl.(grid_rows)
      |> then(&((&1 + 1) * 100))
    end
  end

  def second(input \\ @example) do
    input
    |> parse()
    |> Enum.map(&find_smudge_reflection/1)
    |> Enum.sum()
  end

  defp find_smudge_reflection([h | _t] = grid) do
    grid_cols = Enum.count(h)

    v_refl = fn grid, grid_cols ->
      Enum.find_index(0..(grid_cols - 2), fn ind ->
        refl_range = Enum.min([ind, grid_cols - ind - 2])

        lhs = Enum.map(grid, &Enum.slice(&1, (ind - refl_range)..ind))

        rhs =
          grid
          |> Enum.map(&Enum.slice(&1, (ind + 1)..(ind + 1 + refl_range)))
          |> Enum.map(&Enum.reverse/1)

        diff_count =
          [lhs, rhs]
          |> Enum.zip()
          |> Enum.map(fn {lh_row, rh_row} ->
            [lh_row, rh_row]
            |> Enum.zip()
            |> Enum.count(fn {l, r} -> l != r end)
          end)
          |> Enum.sum()

        diff_count == 1
      end)
    end

    refl = v_refl.(grid, grid_cols)

    if refl do
      refl + 1
    else
      grid_rows = Enum.count(grid)

      grid
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> v_refl.(grid_rows)
      |> then(&((&1 + 1) * 100))
    end
  end
end

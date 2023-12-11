defmodule TwentyThree.Eleven do
  @moduledoc """
  https://adventofcode.com/2023/day/11
  """

  @example """
  ...#......
  .......#..
  #.........
  ..........
  ......#...
  .#........
  .........#
  ..........
  .......#..
  #...#.....
  """

  def input do
    File.read!("priv/day11.txt")
  end

  def parse(input \\ @example) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
  end

  # 9545480
  def first(input \\ @example) do
    data = parse(input)

    empty_rows =
      data
      |> Enum.with_index()
      |> Enum.filter(fn {row, _ind} -> Enum.all?(row, &(&1 == ".")) end)
      |> Enum.map(fn {_row, ind} -> ind end)

    empty_cols =
      data
      |> transpose()
      |> Enum.with_index()
      |> Enum.filter(fn {row, _ind} -> Enum.all?(row, &(&1 == ".")) end)
      |> Enum.map(fn {_row, ind} -> ind end)

    num_columns = data |> List.first() |> Enum.count()

    {_offset, data} =
      Enum.reduce(empty_rows, {0, data}, fn index, {offset, acc} ->
        {offset + 1, add_empty_row(acc, index + offset, num_columns)}
      end)

    num_rows = Enum.count(data)

    {_offset, data} =
      Enum.reduce(empty_cols, {0, data}, fn index, {offset, acc} ->
        {offset + 1, add_empty_column(acc, index + offset, num_rows)}
      end)

    galaxy_positions =
      data
      |> Enum.map(&Enum.with_index/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, i} ->
        Enum.map(row, fn {col, j} ->
          {i, j, col}
        end)
      end)
      |> Enum.filter(fn {_r, _c, v} -> v == "#" end)

    for {i1, j1, _} = i <- galaxy_positions do
      for {i2, j2, _} = j <- galaxy_positions do
        if cmp(i, j), do: abs(i1 - i2) + abs(j1 - j2), else: 0
      end
    end
    |> List.flatten()
    |> Enum.sum()
  end

  def add_empty_row(grid, index, num_columns) do
    Enum.slice(grid, 0..index) ++
      [List.duplicate(".", num_columns)] ++ Enum.slice(grid, (index + 1)..-1//1)
  end

  def add_empty_column(grid, index, num_rows) do
    grid
    |> transpose()
    |> add_empty_row(index, num_rows)
    |> transpose()
  end

  # 406725732046
  def second(input \\ @example) do
    data = parse(input)

    empty_rows =
      data
      |> Enum.with_index()
      |> Enum.filter(fn {row, _ind} -> Enum.all?(row, &(&1 == ".")) end)
      |> Enum.map(fn {_row, ind} -> ind end)

    empty_cols =
      data
      |> transpose()
      |> Enum.with_index()
      |> Enum.filter(fn {row, _ind} -> Enum.all?(row, &(&1 == ".")) end)
      |> Enum.map(fn {_row, ind} -> ind end)

    galaxy_positions =
      data
      |> Enum.map(&Enum.with_index/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, i} ->
        Enum.map(row, fn {col, j} ->
          {i, j, col}
        end)
      end)
      |> Enum.filter(fn {_r, _c, v} -> v == "#" end)

    for {i1, j1, _} = i <- galaxy_positions do
      for {i2, j2, _} = j <- galaxy_positions do
        if cmp(i, j) do
          acc = 0

          acc =
            Enum.reduce(Enum.min([i1, i2])..Enum.max([i1, i2]), acc, fn row, acc ->
              if row in empty_rows, do: acc + 1_000_000, else: acc + 1
            end)

          Enum.reduce(Enum.min([j1, j2])..Enum.max([j1, j2]), acc, fn col, acc ->
            if col in empty_cols, do: acc + 1_000_000, else: acc + 1
          end) - 2
        else
          0
        end
      end
    end
    |> List.flatten()
    |> Enum.sum()
  end

  def transpose(grid) do
    grid
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp cmp({i1, j1, _} = x, {i2, j2, _} = y) do
    cond do
      x == y -> false
      i1 < i2 -> true
      i1 == i2 and j1 < j2 -> true
      true -> false
    end
  end
end

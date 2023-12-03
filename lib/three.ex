defmodule TwentyThree.Three do
  @moduledoc """
  https://adventofcode.com/2023/day/3
  """

  @example """
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
  """

  def input do
    File.read!("priv/day3.txt")
  end

  def parse(input \\ @example) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.codepoints/1)
  end

  # 521515
  def first(input \\ @example) do
    %{nums: nums, symbols: symbols} =
      input
      |> parse()
      |> Enum.map(&Enum.with_index/1)
      |> Enum.map(&Enum.chunk_by(&1, fn {char, _ind} -> symbol_type(char) end))
      |> Enum.map(fn row -> Enum.map(row, &process_chunk/1) end)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, ind} ->
        Enum.map(row, fn {type, val} -> {type, {ind, val}} end)
      end)
      |> Enum.reduce(%{nums: [], symbols: MapSet.new()}, fn {type, val},
                                                            %{nums: nums, symbols: symbols} = acc ->
        case type do
          :empty ->
            acc

          :num ->
            {row, {num, cols}} = val
            %{nums: [{num, {row, cols}} | nums], symbols: symbols}

          :symbol ->
            {row, {_sym, col}} = val
            %{symbols: MapSet.put(symbols, {row, col}), nums: nums}
        end
      end)

    Enum.reduce(nums, 0, fn {num, {row, cols}}, acc ->
      adj_offsets = [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}, {0, 1}, {0, -1}, {1, 0}, {-1, 0}]

      adj_symbol? =
        Enum.any?(adj_offsets, fn {dy, dx} ->
          Enum.any?(cols, &MapSet.member?(symbols, {row + dx, &1 + dy}))
        end)

      if adj_symbol?, do: acc + num, else: acc
    end)
  end

  # 69527306
  def second(input \\ @example) do
    %{nums: nums, symbols: symbols} =
      input
      |> parse()
      |> Enum.map(&Enum.with_index/1)
      |> Enum.map(&Enum.chunk_by(&1, fn {char, _ind} -> symbol_type(char) end))
      |> Enum.map(fn row -> Enum.map(row, &process_chunk/1) end)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, ind} ->
        Enum.map(row, fn {type, val} -> {type, {ind, val}} end)
      end)
      |> Enum.reduce(%{nums: [], symbols: []}, fn {type, val},
                                                  %{nums: nums, symbols: symbols} = acc ->
        case type do
          :empty ->
            acc

          :num ->
            {row, {num, cols}} = val
            %{nums: [{num, {row, cols}} | nums], symbols: symbols}

          :symbol ->
            {row, {sym, col}} = val

            if sym == "*" do
              %{symbols: [{row, col} | symbols], nums: nums}
            else
              acc
            end
        end
      end)

    nums_adj_to = fn {row, col} ->
      adj_offsets = [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}, {0, 1}, {0, -1}, {1, 0}, {-1, 0}]

      Enum.filter(nums, fn {_num, {num_row, num_cols}} ->
        Enum.any?(adj_offsets, fn {dr, dc} ->
          row + dr == num_row and (col + dc) in num_cols
        end)
      end)
    end

    symbols
    |> Enum.reduce(0, fn sym, acc ->
      case nums_adj_to.(sym) do
        [{x, _}, {y, _}] -> acc + x * y
        _ -> acc
      end
    end)
  end

  defp symbol_type(char) do
    case Integer.parse(char) do
      {_num, _} -> :num
      :error when char == "." -> :empty
      :error -> :symbol
    end
  end

  defp process_chunk([{val, ind} | _t] = chunk) do
    case Integer.parse(val) do
      {_num, _} ->
        {_, chunk_end} = List.last(chunk)

        chunk
        |> Enum.map(fn {v, _i} -> String.to_integer(v) end)
        |> Enum.join()
        |> then(&{:num, {String.to_integer(&1), ind..chunk_end}})

      :error when val == "." ->
        {:empty, {ind}}

      :error ->
        {:symbol, {val, ind}}
    end
  end
end

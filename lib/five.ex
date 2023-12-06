defmodule TwentyThree.Five do
  @moduledoc """
  https://adventofcode.com/2023/day/5
  """

  @example """
  seeds: 79 14 55 13

  seed-to-soil map:
  50 98 2
  52 50 48

  soil-to-fertilizer map:
  0 15 37
  37 52 2
  39 0 15

  fertilizer-to-water map:
  49 53 8
  0 11 42
  42 0 7
  57 7 4

  water-to-light map:
  88 18 7
  18 25 70

  light-to-temperature map:
  45 77 23
  81 45 19
  68 64 13

  temperature-to-humidity map:
  0 69 1
  1 0 69

  humidity-to-location map:
  60 56 37
  56 93 4
  """

  def input do
    File.read!("priv/day5.txt")
  end

  def parse(input \\ @example) do
    [["seeds: " <> seeds_str] | other_maps] =
      input
      |> String.trim()
      |> String.split("\n")
      |> Enum.chunk_by(&(&1 == ""))
      |> Enum.reject(&(&1 == [""]))

    seeds =
      seeds_str
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    to_mapping_info = fn [_map_name | maps] ->
      maps
      |> Enum.map(&String.split/1)
      |> Enum.map(fn num_strs -> Enum.map(num_strs, &String.to_integer/1) end)
      |> Enum.map(fn [dest_start, src_start, range] ->
        %{dest: dest_start, src: src_start, range: range}
      end)
    end

    %{seeds: seeds, maps: Enum.map(other_maps, to_mapping_info)}
  end

  # 318728750
  def first(input \\ @example) do
    %{seeds: seeds, maps: maps} = parse(input)

    seeds
    |> Enum.map(&seed_to_location(&1, maps))
    |> Enum.min()
  end

  defp seed_to_location(seed, maps) do
    Enum.reduce(maps, seed, fn mappings, src ->
      mapping = Enum.find(mappings, &(src in &1.src..(&1.src + &1.range)))

      if mapping do
        mapping.dest - mapping.src + src
      else
        src
      end
    end)
  end

  def second(input \\ @example) do
    %{seeds: seeds, maps: maps} = parse(input)

    seed_ranges =
      seeds
      |> Enum.chunk_every(2)
      |> Enum.map(fn [start, range] -> start..(start + range - 1) end)

    seed_ranges
    |> Enum.map(fn seed_range ->
      to_location_ranges(seed_range, maps)
    end)
  end

  defp to_location_ranges(seed_range, maps) do
    Enum.reduce(maps, [seed_range], fn mappings, seed_ranges ->
      Enum.map(seed_ranges, fn seed_range ->
        overlaps =
          mappings
          |> Enum.map(fn mapping ->
            overlap(seed_range, mapping)
          end)
          |> Enum.filter(& &1)
      end)
    end)
  end

  defp overlap(seed_range, %{dest: dest, src: src, range: range}) do
    if Enum.max([seed_range.first, src]) < Enum.min([seed_range.last, src + range - 1]) do
      (dest - src + seed_range.first)..(dest - src + seed_range.last - 1)
    else
      nil
    end
  end
end

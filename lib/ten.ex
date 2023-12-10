defmodule TwentyThree.Ten do
  @moduledoc """
  https://adventofcode.com/2023/day/10


  | is a vertical pipe connecting north and south.
  - is a horizontal pipe connecting east and west.
  L is a 90-degree bend connecting north and east.
  J is a 90-degree bend connecting north and west.
  7 is a 90-degree bend connecting south and west.
  F is a 90-degree bend connecting south and east.
  . is ground; there is no pipe in this tile.
  S is the starting position of the animal;
  there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
  """

  @example """
  ..F7.
  .FJ|.
  SJ.L7
  |F--J
  LJ...
  """

  @north_d {-1, 0}
  @east_d {0, 1}
  @south_d {1, 0}
  @west_d {0, -1}

  @pipe_map %{
    "|" => [@north_d, @south_d],
    "-" => [@east_d, @west_d],
    "L" => [@north_d, @east_d],
    "J" => [@north_d, @west_d],
    "7" => [@south_d, @west_d],
    "F" => [@south_d, @east_d]
  }

  def input do
    File.read!("priv/day10.txt")
  end

  def parse(input \\ @example) do
    parse_line = fn {line, row} ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn {char, col} ->
        connected = Map.get(@pipe_map, char, char)
        {{row, col}, connected}
      end)
    end

    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(parse_line)
    |> Map.new()
  end

  # 6923
  def first(input \\ @example) do
    connections =
      input
      |> parse()
      |> Enum.map(fn
        {{r, c}, [{dr1, dc1}, {dr2, dc2}]} ->
          {{r, c}, [{r + dr1, c + dc1}, {r + dr2, c + dc2}]}

        {{r, c}, v} ->
          {{r, c}, [v]}
      end)
      |> Map.new()

    {{sr, sc}, ["S"]} = Enum.find(connections, fn {_, val} -> val == ["S"] end)
    {{r1, c1}, _} = Enum.find(connections, fn {_, conn} -> {sr, sc} in conn end)

    step({sr, sc}, {sr, sc}, {r1, c1}, connections) |> div(2)
  end

  defp step(src, prev_pos, current_pos, pos_map, acc \\ 1) do
    case current_pos do
      ^src ->
        acc

      {r, c} ->
        current_conns = pos_map[{r, c}]
        next_pos = Enum.find(current_conns, &(&1 != prev_pos))

        step(src, current_pos, next_pos, pos_map, acc + 1)
    end
  end

  @third_example """
  .F----7F7F7F7F-7....
  .|F--7||||||||FJ....
  .||.FJ||||||||L7....
  FJL7L7LJLJ||LJ.L-7..
  L--J.L7...LJS7F-7L7.
  ....F-J..F7FJ|L7L7L7
  ....L7.F7||L7|.L7L7|
  .....|FJLJ|FJ|F7|.LJ
  ....FJL-7.||.||||...
  ....L---J.LJ.LJLJ...
  """

  # 529
  def second(input \\ @third_example) do
    deltas = parse(input)

    connections =
      deltas
      |> Enum.map(fn
        {{r, c}, [{dr1, dc1}, {dr2, dc2}]} ->
          {{r, c}, [{r + dr1, c + dc1}, {r + dr2, c + dc2}]}

        {{r, c}, v} ->
          {{r, c}, [v]}
      end)
      |> Map.new()

    {{sr, sc}, ["S"]} = Enum.find(connections, fn {_, val} -> val == ["S"] end)
    {{r1, c1}, _} = Enum.find(connections, fn {_, conn} -> {sr, sc} in conn end)

    loop_tiles = loop_tiles({sr, sc}, {sr, sc}, {r1, c1}, connections, [{sr, sc}, {r1, c1}])
    crossing_deltas = [[@north_d, @east_d], [@south_d, @west_d]]

    connections
    |> Enum.map(fn {key, _val} -> key end)
    |> Enum.reduce(0, fn {r, c}, acc ->
      if Enum.member?(loop_tiles, {r, c}) do
        acc
      else
        windings =
          Enum.reduce(0..r, [], fn i, acc ->
            if Enum.member?(loop_tiles, {r - i, c - i}) and
                 Map.get(deltas, {r - i, c - i}) not in crossing_deltas do
              [{r - i, c - i} | acc]
            else
              acc
            end
          end)

        winding_num = Enum.count(windings)

        if rem(winding_num, 2) == 1 do
          acc + 1
        else
          acc
        end
      end
    end)
  end

  defp loop_tiles(src, prev_pos, current_pos, pos_map, acc) do
    case current_pos do
      ^src ->
        MapSet.new(acc)

      {r, c} ->
        current_conns = pos_map[{r, c}]
        next_pos = Enum.find(current_conns, &(&1 != prev_pos))

        loop_tiles(src, current_pos, next_pos, pos_map, [next_pos | acc])
    end
  end
end

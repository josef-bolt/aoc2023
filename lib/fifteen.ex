defmodule TwentyThree.Fifteen do
  @moduledoc """
  https://adventofcode.com/2023/day/15
  """

  @example """
  rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
  """

  def input do
    File.read!("priv/day15.txt")
  end

  def parse(input \\ @example) do
    input
    |> String.trim()
    |> String.split(",")
  end

  # 498538
  def first(input \\ @example) do
    input
    |> parse()
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  # 286278
  def second(input \\ @example) do
    input
    |> parse()
    |> Enum.reduce(%{}, fn val, acc ->
      [box_id, op, foc] = Regex.split(~r/=|-/, val, include_captures: true)

      box_num = hash(box_id)
      box = Map.get(acc, box_num, [])

      updated_box =
        case op do
          "-" ->
            ind = Enum.find_index(box, fn {id, _f} -> id == box_id end)
            if ind, do: List.delete_at(box, ind), else: box

          "=" ->
            ind = Enum.find_index(box, fn {id, _f} -> id == box_id end)

            if ind do
              List.replace_at(box, ind, {box_id, String.to_integer(foc)})
            else
              [{box_id, String.to_integer(foc)} | box]
            end
        end

      Map.put(acc, box_num, updated_box)
    end)
    |> Enum.map(fn {id, box} -> {id, Enum.reverse(box)} end)
    |> Enum.reduce(0, fn {id, box}, acc ->
      box_str =
        box
        |> Enum.with_index(1)
        |> Enum.map(fn {{_box_id, foc}, ind} ->
          (id + 1) * ind * foc
        end)
        |> Enum.sum()

      acc + box_str
    end)
  end

  defp hash(str) do
    str
    |> String.to_charlist()
    |> Enum.reduce(0, fn char, acc ->
      rem((acc + char) * 17, 256)
    end)
  end
end

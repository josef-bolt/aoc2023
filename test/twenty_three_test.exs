defmodule TwentyThreeTest do
  use ExUnit.Case
  doctest TwentyThree

  test "greets the world" do
    assert TwentyThree.hello() == :world
  end
end

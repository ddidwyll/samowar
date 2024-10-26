defmodule SamowarTest do
  use ExUnit.Case
  doctest Samowar

  test "greets the world" do
    assert Samowar.hello() == :world
  end
end

defmodule LagunaIpcTest do
  use ExUnit.Case
  doctest LagunaIpc

  test "greets the world" do
    assert LagunaIpc.hello() == :world
  end
end

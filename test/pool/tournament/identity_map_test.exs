defmodule Pool.Tournament.IdentityMapTest do
  use ExUnit.Case, async: true

  alias Pool.Tournament.IdentityMap

  setup :create_registry

  describe "Pool.AggregateIdentityMap.lookup/2" do
    test "returns :error when the process is not registered", %{registry: registry} do
      assert IdentityMap.lookup(registry, "non-existent") == :error
    end

    test "returns {:ok, pid} when the process is registered", %{registry: registry} do
      {:ok, pid} = IdentityMap.create(registry, "no-op")
      assert ^pid = IdentityMap.lookup(registry, "no-op")
    end
  end

  describe "process monitoring" do
    test "removes aggregate on crash", %{registry: registry} do
      id = "aggregate-id"
      {:ok, pid} = IdentityMap.create(registry, id)
      Process.exit(pid, :shutown)

      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}

      assert IdentityMap.lookup(registry, id) == :error
    end
  end

  def create_registry(context) do
    {:ok, pid} = IdentityMap.start_link(context.test)
    %{registry: pid}
  end
end

defmodule Pool.AggregateIdentityMapTest do
  use ExUnit.Case, async: true

  setup :create_registry

  describe "Pool.AggregateIdentityMap.lookup/2" do
    test "returns :error when the process is not registered", %{registry: registry} do
      assert Pool.AggregateIdentityMap.lookup(registry, "non-existent") == :error
    end

    test "returns {:ok, pid} when the process is registered", %{registry: registry} do
      {:ok, pid} = Pool.AggregateIdentityMap.create(registry, "no-op")
      assert ^pid = Pool.AggregateIdentityMap.lookup(registry, "no-op")
    end
  end

  describe "process monitoring" do
    test "removes aggregate on crash", %{registry: registry} do
      id = "aggregate-id"
      {:ok, pid} = Pool.AggregateIdentityMap.create(registry, id)
      Process.exit(pid, :shutown)

      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}

      assert Pool.AggregateIdentityMap.lookup(registry, id) == :error
    end
  end

  def create_registry(context) do
    {:ok, pid} = Pool.AggregateIdentityMap.start_link(context.test)
    %{registry: pid}
  end
end

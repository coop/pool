defmodule Pool.AggregateRegistryTest do
  use ExUnit.Case, async: true

  setup :create_registry

  describe "Pool.AggregateRegistry.lookup/2" do
    test "returns :error when the process is not registered", %{registry: registry} do
      assert Pool.AggregateRegistry.lookup(registry, "non-existent") == :error
    end

    test "returns {:ok, pid} when the process is registered", %{registry: registry} do
      {:ok, pid} = Pool.AggregateRegistry.create(registry, "no-op")
      assert ^pid = Pool.AggregateRegistry.lookup(registry, "no-op")
    end
  end

  describe "process monitoring" do
    test "removes aggregate on crash", %{registry: registry} do
      id = "aggregate-id"
      {:ok, pid} = Pool.AggregateRegistry.create(registry, id)
      Process.exit(pid, :shutown)

      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}

      assert Pool.AggregateRegistry.lookup(registry, id) == :error
    end
  end

  def create_registry(context) do
    {:ok, pid} = Pool.AggregateRegistry.start_link(context.test)
    %{registry: pid}
  end
end

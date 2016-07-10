defmodule Pool.AggregateRepositoryTest do
  use ExUnit.Case, async: true

  setup :generate_id

  describe "Pool.AggregateRepoitory.save/2" do
    test "makes the  uncommitted_changes available for saving", %{id: id} do
      Process.register(self, :test)

      save_events = fn(id, events) ->
        send :test, {id, Enum.count(events)}
      end

      {:ok, pid} = Pool.AggregateRegistry.create(Pool.AggregateRegistry, id)
      Pool.Tournament.open_for_registration(pid, id)
      Pool.Tournament.register_player(pid, "tim")
      Pool.AggregateRepository.save(pid, save_events)

      assert_received {^id, 2}
    end
  end

  describe "Pool.AggregateRepoitory.load/1" do
    test "loads from the registry when present", %{id: id} do
      {:ok, pid} = Pool.AggregateRegistry.create(Pool.AggregateRegistry, id)

      assert Pool.AggregateRepository.load(id) == {:ok, pid}
    end

    test "errors when the aggregate do not exist", %{id: id} do
      assert Pool.AggregateRepository.load(id) == :error
    end
  end

  # Unique ids are required because Pool.AggregateRegistry is shared global
  # state between tests.
  defp generate_id(context) do
    %{id: UUID.uuid5(:dns, "my.domain.com/#{context.test}")}
  end
end

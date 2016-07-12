defmodule Pool.Tournament.RepositoryTest do
  use ExUnit.Case, async: true

  alias Pool.Tournament.{IdentityMap, Repository}

  setup :generate_id

  describe "Pool.AggregateRepoitory.save/2" do
    test "makes the  uncommitted_changes available for saving", %{id: id} do
      Process.register self, :fuck

      save_events = fn(id, events) ->
        send :fuck, {id, Enum.count(events)}
      end

      {:ok, pid} = IdentityMap.create(IdentityMap, id)
      Pool.Tournament.open_for_registration(pid, id)
      Pool.Tournament.register_player(pid, "tim")
      Repository.save(pid, save_events)

      assert_received {^id, 2}
    end
  end

  describe "Pool.AggregateRepoitory.load/1" do
    test "loads from the registry when present", %{id: id} do
      {:ok, pid} = IdentityMap.create(IdentityMap, id)

      assert Repository.load(id) == {:ok, pid}
    end

    test "errors when the aggregate do not exist", %{id: id} do
      assert Pool.Tournament.Repository.load(id) == :not_found
    end
  end

  # Unique ids are required because Pool.Tournament.IdentityMap is shared global
  # state between tests.
  defp generate_id(context) do
    %{id: UUID.uuid5(:dns, "my.domain.com/#{context.test}")}
  end
end

defmodule Pool.AggregateRepository do
  @moduledoc """
  Docs ...

  Examples:

      {:ok, pid} = Pool.AggregateIdentityMap.create(Pool.AggregateIdentityMap, id)
      Pool.Tournament.open_for_registration(pid, player_id)
      Pool.Tournament.register_player(pid, player_id)
      Pool.Repository.save(pid)

      {:ok, pid} = Pool.Repository.load(id)
      Pool.Tournament.register_player(pid, player_id)
      :ok = Pool.Repository.save(pid)

  """

  def save(pid) do
    save_events = fn(id, events) ->
      Pool.EventStore.save_events(id, events)
    end

    save(pid, save_events)
  end

  def save(pid, fun) do
    Pool.Tournament.process_uncommitted_changes(pid, fun)
  end

  def load(id) do
    case Pool.AggregateIdentityMap.lookup(Pool.AggregateIdentityMap, id) do
      :error -> load_from_event_store(id)
      pid -> {:ok, pid}
    end
  end

  defp load_from_event_store(id) do
    case Pool.EventStore.load_events(id) do
      [] ->
        :not_found
      events ->
        {:ok, pid} = Pool.AggregateIdentityMap.create(Pool.AggregateIdentityMap, id)
        Pool.Tournament.load_from_history(pid, events)
        {:ok, pid}
    end
  end
end

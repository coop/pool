defmodule Pool.Tournament.Repository do
  alias Pool.Tournament.IdentityMap

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
    case IdentityMap.lookup(IdentityMap, id) do
      :error -> load_from_event_store(id)
      pid -> {:ok, pid}
    end
  end

  defp load_from_event_store(id) do
    case Pool.EventStore.load_events(id) do
      [] ->
        :not_found
      events ->
        {:ok, pid} = IdentityMap.create(IdentityMap, id)
        Pool.Tournament.load_from_history(pid, events)
        {:ok, pid}
    end
  end
end

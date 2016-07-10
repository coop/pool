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

  def save(pid, fun) do
    Pool.Tournament.process_uncommitted_changes(pid, fun)
  end

  def load(id) do
    case Pool.AggregateIdentityMap.lookup(Pool.AggregateIdentityMap, id) do
      :error -> :error
      pid -> {:ok, pid}
    end
  end
end

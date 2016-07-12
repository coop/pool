defmodule Pool.TournamentCommandHandler do
  use GenEvent

  def handle_event(%Pool.Tournament.OpenForRegistration{id: id}, state) do
    {:ok, pid} = Pool.AggregateIdentityMap.create(Pool.AggregateIdentityMap, id)
    Pool.Tournament.open_for_registration(pid, id)
    Pool.AggregateRepository.save(pid)
    {:ok, state}
  end

  def handle_event(%Pool.Tournament.RegisterPlayer{id: id, player_id: player_id}, state) do
    {:ok, pid} = Pool.AggregateRepository.load(id)
    Pool.Tournament.register_player(pid, player_id)
    Pool.AggregateRepository.save(pid)
    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end

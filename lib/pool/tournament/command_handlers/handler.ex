defmodule Pool.Tournament.CommandHandlers.Handler do
  use GenEvent

  alias Pool.Tournament.{IdentityMap, Repository}
  alias Pool.Tournament.Commands.{OpenForRegistration, RegisterPlayer}

  def handle_event(%OpenForRegistration{id: id}, state) do
    {:ok, pid} = IdentityMap.create(IdentityMap, id)
    Pool.Tournament.open_for_registration(pid, id)
    Repository.save(pid)

    {:ok, state}
  end

  def handle_event(%RegisterPlayer{id: id, player_id: player_id}, state) do
    {:ok, pid} = Repository.load(id)
    Pool.Tournament.register_player(pid, player_id)
    Repository.save(pid)

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end
end

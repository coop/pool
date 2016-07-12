defmodule Pool.Tournament.ReadModels.Report do
  use GenEvent

  alias Pool.Tournament.Events.{OpenedForRegistration, PlayerRegistered}

  def init([]) do
    {:ok, %{}}
  end

  # TODO: store information suitable for displaying tournaments in whatever
  # fashion redux requires... Right now I will do something trivial:
  #
  #     "id" => {
  #       player_ids: [ ... ],
  #     }
  def handle_event(%OpenedForRegistration{id: id}, state) do
    state = Map.put(state, id, %{player_ids: []})

    {:ok, state}
  end

  def handle_event(%PlayerRegistered{id: id, player_id: player_id}, state) do
    state = Kernel.update_in state, [id, :player_ids], fn(player_ids) ->
      [player_id | player_ids]
    end

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end

  def handle_call({:players_in, id}, state) do
    player_ids = Enum.reverse(Kernel.get_in(state, [id, :player_ids]))

    {:ok, player_ids, state}
  end
end

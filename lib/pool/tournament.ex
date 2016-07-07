defmodule Pool.Tournament do
  use GenServer

  def start_link(id) do
    GenServer.start_link(__MODULE__, id)
  end

  def init(id) do
    state = %{
      id: id,
      player_ids: [],
      uncommitted_changes: [],
    }

    {:ok, state}
  end

  def register_player(pid, player_id) do
    GenServer.call(pid, {:register_player, player_id})
  end

  def load_from_history(pid, events) do
    GenServer.call(pid, {:load_from_history, events})
  end

  def process_uncommitted_changes(pid, fun) do
    GenServer.call(pid, {:process_uncommitted_changes, fun})
  end

  # TODO: A player cannot register ...
  #
  # * if registrations are closed
  # * if they have already registered
  def handle_call({:register_player, player_id}, _from, state) do
    if player_id in state.player_ids do
      {:reply, player_id, state}
    else
      event = %Pool.Tournament.PlayerRegistered{
        id: state.id,
        player_id: player_id,
      }

      {:reply, player_id, raise_event(event, state)}
    end
  end

  def handle_call({:load_from_history, events}, _form, state) do
    {:reply, :ok, apply_events(events, state)}
  end

  def handle_call({:process_uncommitted_changes, fun}, _from, state) do
    fun.(state.id, state.uncommitted_changes)
    state = Map.put(state, :uncommitted_changes, [])

    {:reply, :ok, state}
  end

  defp raise_event(event, state) do
    Map.update! apply_event(event, state), :uncommitted_changes, fn(events) ->
      [event | events]
    end
  end

  defp apply_events([], state) do
    state
  end

  defp apply_events([event | events], state) do
    apply_events(events, apply_event(event, state))
  end

  defp apply_event(%Pool.Tournament.PlayerRegistered{player_id: player_id}, state) do
    Map.update! state, :player_ids, fn(player_ids) ->
      [player_id | player_ids]
    end
  end
end

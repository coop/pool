defmodule Pool.TournamentTest do
  use ExUnit.Case, async: true

  describe "Pool.Tournament.register_player/2" do
    test "allows a player to register" do
      Process.register self, :test

      {:ok, pid} = Pool.Tournament.start_link("lol")
      Pool.Tournament.register_player(pid, "tim")
      callback = fn(id, events) ->
        send :test, {:count, id, Enum.count(events)}
      end

      Pool.Tournament.process_uncommitted_changes(pid, callback)

      assert_received {:count, "lol", 1}
    end

    test "players cannot register more than once" do
      Process.register self, :test

      {:ok, pid} = Pool.Tournament.start_link("lol")
      Pool.Tournament.register_player(pid, "tim")
      Pool.Tournament.register_player(pid, "tim")
      Pool.Tournament.register_player(pid, "tim")
      Pool.Tournament.register_player(pid, "tammy")
      callback = fn(id, events) ->
        send :test, {:count, id, Enum.count(events)}
      end

      Pool.Tournament.process_uncommitted_changes(pid, callback)

      assert_received {:count, "lol", 2}
    end
  end

  describe "Pool.Tournament.load_from_history/2" do
    test "loading from existing events" do
      Process.register self, :test

      {:ok, pid_1} = Pool.Tournament.start_link("lol")
      Pool.Tournament.register_player(pid_1, "tim")
      Pool.Tournament.register_player(pid_1, "tammy")
      get_events = fn(_id, events) ->
        send :test, {:events, events}
      end

      Pool.Tournament.process_uncommitted_changes(pid_1, get_events)

      events = receive do
        {:events, events} -> events
      end

      {:ok, pid_2} = Pool.Tournament.start_link("lol")
      Pool.Tournament.load_from_history(pid_2, Enum.reverse(events))
      Pool.Tournament.register_player(pid_2, "tim")
      Pool.Tournament.register_player(pid_2, "tammy")
      Pool.Tournament.process_uncommitted_changes(pid_2, get_events)

      assert_received {:events, []}
    end
  end
end

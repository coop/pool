defmodule PoolTest do
  use ExUnit.Case, async: true

  defmodule ExampleHandler do
    use GenEvent

    def init(pid) do
      {:ok, pid}
    end

    def handle_event(event, pid) do
      send pid, event
      {:ok, pid}
    end
  end

  test "end to end" do
    tournament_1 = generate_id
    tournament_2 = generate_id
    player_1 = generate_id
    player_2 = generate_id
    player_3 = generate_id

    Pool.Bus.add_handler(ExampleHandler, self)

    Pool.Bus.send_command(%Pool.Tournament.OpenForRegistration{id: tournament_1})
    Pool.Bus.send_command(%Pool.Tournament.RegisterPlayer{id: tournament_1, player_id: player_1})
    Pool.Bus.send_command(%Pool.Tournament.RegisterPlayer{id: tournament_1, player_id: player_2})

    Pool.Bus.send_command(%Pool.Tournament.OpenForRegistration{id: tournament_2})
    Pool.Bus.send_command(%Pool.Tournament.RegisterPlayer{id: tournament_2, player_id: player_3})

    # GenEvent.notify is async so I'm registering a handler that forwards all
    # events to the test process. Alternatively I could :timer.sleep(10) but
    # that feels gross... This is super verbose though... Ugh.
    assert_receive %Pool.Tournament.OpenForRegistration{id: ^tournament_1}, 10
    assert_receive %Pool.Tournament.RegisterPlayer{id: ^tournament_1, player_id: ^player_1}, 10
    assert_receive %Pool.Tournament.RegisterPlayer{id: ^tournament_1, player_id: ^player_2}, 10
    assert_receive %Pool.Tournament.OpenForRegistration{id: ^tournament_2}, 10
    assert_receive %Pool.Tournament.RegisterPlayer{id: ^tournament_2, player_id: ^player_3}, 10

    assert [^player_3] = Pool.Bus.players_in(tournament_2)
    assert [^player_1, ^player_2] = Pool.Bus.players_in(tournament_1)
  end

  defp generate_id do
    UUID.uuid4
  end
end

defmodule Pool.EventStore do
  # TODO: save events to a database.
  def save_events(_id, events) do
    Enum.each Enum.reverse(events), fn(event) ->
      Pool.Bus.publish_event(event)
    end
  end

  def load_events(_id) do
    []
  end
end

defmodule Pool.Bus do
  use GenEvent

  @name __MODULE__

  def start_link do
    case GenEvent.start_link(name: @name) do
      {:ok, pid} ->
        add_handler(Pool.Tournament.ReadModels.Report)
        add_handler(Pool.Tournament.CommandHandlers.Handler)
        {:ok, pid}
    end
  end

  def add_handler(handler, args \\ []) do
    GenEvent.add_handler(@name, handler, args)
  end

  def players_in(id) do
    GenEvent.call(@name, Pool.Tournament.ReadModels.Report, {:players_in, id})
  end

  def publish_event(event) do
    GenEvent.notify(@name, event)
  end

  def send_command(command) do
    GenEvent.notify(@name, command)
  end
end

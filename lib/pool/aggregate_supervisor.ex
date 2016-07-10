defmodule Pool.AggregateSupervisor do
  @moduledoc """
  Docs ...

  Examples:

      {:ok, pid} = Pool.AggregateSupervisor.new(Pool.Tournament)

  """

  def start_link(module) do
    import Supervisor.Spec

    children = [
      worker(module, []),
    ]

    opts = [strategy: :simple_one_for_one, name: module]
    Supervisor.start_link(children, opts)
  end

  def new(module) do
    Supervisor.start_child(module, [])
  end
end

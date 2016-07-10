defmodule Pool.AggregateSupervisor do
  @moduledoc """
  Docs ...

  Examples:

      {:ok, pid} = Pool.AggregateSupervisor.new(Pool.Tournament)

  """

  def start_link(module) do
    import Supervisor.Spec

    children = [
      # NOTE: This supervisor is only being used to group processes but
      # specifically not being used to restart the process. This might seem odd
      # but aggregates are created via the repository and monitored via the
      # registry.
      worker(module, [], restart: :temporary),
    ]

    opts = [strategy: :simple_one_for_one, name: module]
    Supervisor.start_link(children, opts)
  end

  def new(module) do
    Supervisor.start_child(module, [])
  end
end

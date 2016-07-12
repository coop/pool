defmodule Pool.Tournament.AggregateRootSupervisor do
  def start_link(name) do
    import Supervisor.Spec

    children = [
      worker(Pool.Tournament, [], restart: :temporary),
    ]

    opts = [strategy: :simple_one_for_one, name: name]
    Supervisor.start_link(children, opts)
  end

  def new(pid) do
    Supervisor.start_child(pid, [])
  end
end

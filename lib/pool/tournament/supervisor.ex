defmodule Pool.Tournament.Supervisor do
  alias Pool.Tournament.{IdentityMap, AggregateRootSupervisor}

  def start_link(name) do
    import Supervisor.Spec

    children = [
      worker(IdentityMap, [IdentityMap]),
      supervisor(AggregateRootSupervisor, [AggregateRootSupervisor]),
    ]

    opts = [strategy: :rest_for_one, name: name]
    Supervisor.start_link(children, opts)
  end
end

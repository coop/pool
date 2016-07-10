defmodule Pool do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # TODO: re-evaluate if this supervision tree is correct. At this stage
      # there is a supervisor per aggregate type that manages individual
      # aggregates BUT there is a shared identity map between all aggregates.
      # If the map fails all aggregate type supervisors (and therefore
      # aggregates) need to be restarted. Right now I'm OK with this but maybe
      # an identity map per type is a better approach.
      worker(Pool.AggregateIdentityMap, [Pool.AggregateIdentityMap]),
      supervisor(Pool.AggregateSupervisor, [Pool.Tournament]),
    ]

    opts = [strategy: :rest_for_one, name: Pool.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

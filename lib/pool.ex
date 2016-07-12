defmodule Pool do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Pool.Bus, []),
      supervisor(Pool.Tournament.Supervisor, [Pool.Tournament.Supervisor]),
    ]

    opts = [strategy: :one_for_one, name: Pool.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

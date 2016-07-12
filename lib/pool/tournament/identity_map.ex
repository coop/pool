defmodule Pool.Tournament.IdentityMap do
  use GenServer

  alias Pool.Tournament.AggregateRootSupervisor

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init([]) do
    {:ok, {%{}, %{}}}
  end

  def create(server, id) do
    GenServer.call(server, {:create, id})
  end

  def lookup(server, id) do
    GenServer.call(server, {:lookup, id})
  end

  def handle_call({:create, id}, _from, {pids, refs} = state) do
    pid = Map.get(pids, id, false)
    if pid do
      {:reply, {:ok, pid}, state}
    else
      {:ok, pid} = AggregateRootSupervisor.new(AggregateRootSupervisor)
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, id)
      pids = Map.put(pids, id, pid)

      {:reply, {:ok, pid}, {pids, refs}}
    end
  end

  def handle_call({:lookup, id}, _from, {pids, _refs} = state) do
    {:reply, Map.get(pids, id, :error), state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {pids, refs}) do
    {id, refs} = Map.pop(refs, ref)
    pids = Map.delete(pids, id)

    {:noreply, {pids, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end

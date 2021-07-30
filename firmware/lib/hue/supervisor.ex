defmodule Hue.Supervisor do
  use Supervisor

  alias Hue.Monitor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children = [
      {Registry, name: Hue.Registry, keys: :duplicate},
      {Monitor, name: Hue.Monitor}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end

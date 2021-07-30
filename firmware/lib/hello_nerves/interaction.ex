defmodule HelloNerves.Interaction do
  use GenServer
  require Logger

  # todo must be {:global, :interaction_server} ??
  @name :interaction_server

  def start_link(_params) do
    GenServer.start_link(__MODULE__, nil, name: @name)
  end

  def trigger_action() do
    GenServer.call(@name, :trigger)
  end

  ### Server

  @impl true
  def init(_params), do: {:ok, nil}

  @impl true
  def handle_call(:trigger, _from, state) do
    Logger.info("Action in Firmware triggered!")
    {:reply, :ok, nil}
  end
end

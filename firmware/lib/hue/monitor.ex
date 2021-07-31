defmodule Hue.Monitor do
  use GenServer
  require Logger

  alias Hue.{Client, Group, Light, Scene}

  @registry Hue.Registry
  @monitor __MODULE__
  # 2sec
  @refresh_time 2_000

  @impl true
  def init(_opts) do
    schedule_refresh()
    state =
      %{lights: [], groups: []}
      |> reload_from_registry()
    {:ok, state}
  end

  @doc "If the monitor crashes, the registry remains. Query it to find previously registered lights/groups"
  defp reload_from_registry(state) do
    Hue.Registry
    |> Registry.select([{{:_, :_, :"$1"}, [], [:"$1"]}])
    |> MapSet.new()
    |> Enum.reduce(state, fn
      {:light, id}, acc ->
        {:ok, %{body: body}} = Hue.Client.light(id)
        light = Light.from_response(id, body)
        Map.update!(acc, :lights, &([light | &1]))
      {:group, id}, acc -> Hue.Client.group(id)
        {:ok, %{body: body}} = Hue.Client.group(id)
        group = Group.from_response(id, body)
        Map.update!(acc, :groups, &([group | &1]))
    end)
  end

  # todo how to handle a process de-registering because crash -> Don't refresh that light/group anymore.

  @impl true
  def handle_info(:refresh, state) do
    state =
      state
      |> Map.update!(:lights, fn lights ->
        Enum.map(lights, fn light ->
          case Client.refresh(light) do
            {:ok, refreshed} ->
              refreshed

            {:error, reason} ->
              Logger.warning(
                "Couldn't refresh Hue light: #{inspect(light)} -> #{inspect(reason)}"
              )

              light
          end
        end)
      end)
      |> Map.update!(:groups, fn groups ->
        Enum.map(groups, fn {group, scene} ->
          case Client.refresh(group) do
            {:ok, refreshed} ->
              {refreshed, scene}

            {:error, reason} ->
              Logger.warning(
                "Couldn't refresh Hue group: #{inspect(group)} -> #{inspect(reason)}"
              )

              {group, scene}
          end
        end)
      end)

    # todo optimization: Only do this if light actually changed.
    Enum.each(state.lights, fn light ->
      Registry.dispatch(@registry, light.uid, fn entries ->
        for {pid, _value} <- entries, do: send(pid, {:hue_update, light})
      end)
    end)

    # todo optimization: Only do this if light actually changed.
    Enum.each(state.groups, fn {group, _scene} ->
      Registry.dispatch(@registry, group.uid, fn entries ->
        for {pid, _value} <- entries, do: send(pid, {:hue_update, group})
      end)
    end)

    schedule_refresh()
    {:noreply, state}
  end

  @impl true
  def handle_info(_any, state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:reg_light, name}, _from, %{lights: lights} = state) do
    case find_light(name) do
      {:ok, light} ->
        state = Map.put(state, :lights, [light | lights])
        {:reply, {:ok, light}, state}

      {:error, _} = err ->
        {:reply, err, state}
    end
  end

  @impl true
  def handle_call({:reg_group, name, scene_name}, _from, %{groups: groups} = state) do
    with {:ok, group} <- find_group(name),
         {:ok, scene} <- find_scene(scene_name) do
      state = Map.put(state, :groups, [{group, scene} | groups])
      {:reply, {:ok, group}, state}
    else
      {:error, _} = err -> {:reply, err, state}
    end
  end

  defp schedule_refresh, do: Process.send_after(self(), :refresh, @refresh_time)

  ## --- PUBLIC API ---

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def register_light(name) do
    with {:ok, light} <- GenServer.call(@monitor, {:reg_light, name}) do
      Registry.register(@registry, light.uid, {:light, light.id})
      :ok
    end
  end

  def register_group(name) do
    with {:ok, group} <- GenServer.call(@monitor, {:reg_group, name}) do
      # todo this "forgets" about the scene!
      Registry.register(@registry, group.uid, {:group, group.id})
      :ok
    end
  end

  ## --- HELPERS ----

  @spec find_light(String.t()) :: {:ok, %Light{}} | {:error, String.t()}
  defp find_light(light_name) do
    with {:ok, id, info} <- find_by_id(Client.lights(), fn info -> info["name"] == light_name end) do
      {:ok, Light.from_response(id, info)}
    end
  end

  @spec find_group(String.t()) :: {:ok, %Group{}} | {:error, String.t()}
  defp find_group(group_name) do
    with {:ok, id, info} <- find_by_id(Client.groups(), fn info -> info["name"] == group_name end) do
      {:ok, Group.from_response(id, info)}
    end
  end

  @spec find_scene(String.t()) :: {:ok, %Scene{}} | {:error, String.t()}
  defp find_scene(scene_name) do
    with {:ok, id, info} <- find_by_id(Client.scenes(), fn info -> info["name"] == scene_name end) do
      {:ok, Scene.from_response(id, info)}
    end
  end

  defp find_by_id({:ok, %{body: body}}, select_fn) do
    body
    |> Enum.find(fn {_id, name} -> select_fn.(name) end)
    |> case do
      nil -> {:error, "Hue item not found"}
      {id, info} -> {:ok, id, info}
    end
  end

  defp find_by_id({:error, _} = error, _select_fn), do: error
end

defmodule HelloNerves.Component.LightSwitch do
  use Scenic.Component

  alias Scenic.Graph
  import Scenic.Primitives

  @graph Graph.build()
         |> circle(30, id: :on_indicator, stroke: {2, :yellow}, translate: {20, 20})
         |> text("[name]", id: :name, text_align: :center, translate: {20, 70})

  @impl true
  def verify(light_name) when is_bitstring(light_name) do
    {:ok, light_name}
  end

  def verify(_), do: :invalid_data

  @impl true
  def info(_data), do: "Scene arg was expected to be Hue Light name as a string."

  @impl true
  def init(light_name, _opts) do
    :ok = Hue.Monitor.register_light(light_name)
    {:ok, nil, push: @graph}
  end

  @impl true
  def handle_info({:hue_update, light}, _state) do
    {:noreply, light, push: update_graph(light)}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  @impl true
  def handle_input(
        {:cursor_button, {:left, :release, _, _}},
        _context,
        state
      ) do
    case Hue.Client.toggle(state) do
      {:ok, light} ->
        {:halt, light, push: update_graph(light)}

      {:error, reason} ->
        IO.puts("Couldn't switch #{inspect(reason)}")
        {:halt, state}
    end
  end

  @impl true
  def handle_input(_input, _context, state), do: {:cont, state}

  defp update_graph(%Hue.Light{name: name, is_on?: on?}) do
    @graph
    |> Graph.modify(:name, &text(&1, name))
    |> Graph.modify(:on_indicator, &circle(&1, 30, fill: indicator_color(on?)))
  end

  defp indicator_color(true), do: :yellow
  defp indicator_color(false), do: :clear
end

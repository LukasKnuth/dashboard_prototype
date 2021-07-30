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
    {:ok, [], push: @graph}
  end

  @impl true
  def handle_info({:hue_update, %Hue.Light{name: name, is_on?: on?}}, state) do
    graph = @graph
    |> Graph.modify(:name, &text(&1, name))
    |> Graph.modify(:on_indicator, &circle(&1, 30, fill: indicator_color(on?)))
    {:noreply, state, push: graph}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def indicator_color(true), do: :yellow
  def indicator_color(false), do: :clear
end

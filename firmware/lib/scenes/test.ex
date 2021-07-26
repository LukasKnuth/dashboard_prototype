defmodule HelloNerves.Scene.Test do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components

  @graph Graph.build()
    |> text("My first scene", id: :txt_hello, font_size: 22, translate: {100, 100})
    |> button("Click me!", id: :btn_invoke, translate: {100, 150})
    |> button("Reset", id: :btn_reset, translate: {100, 200})

  @impl true
  def init(_scene_args, _options) do
    state = %{count: 0}
    {:ok, state, push: @graph}
  end

  @impl true
  def filter_event({:click, :btn_invoke}, _from, state) do
    state = %{count: click_count} = Map.update!(state, :count, &(&1 + 1))
    graph = update_count_text(click_count)
    {:halt, state, push: graph}
  end

  @impl true
  def filter_event({:click, :btn_reset}, _from, state) do
    state = Map.put(state, :count, 0)
    graph = update_count_text(0)
    {:halt, state, push: graph}
  end

  defp update_count_text(click_count) do
    Graph.modify(@graph, :txt_hello, &text(&1, "Button clicked #{click_count}"))
  end
end

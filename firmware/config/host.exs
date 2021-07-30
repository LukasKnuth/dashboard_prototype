import Config

# Add configuration that is only needed when running on the host here.

config :hello_nerves, :viewport, %{
  name: :main_viewport,
  default_scene: {HelloNerves.Scene.Test, nil},
  size: {1024, 600},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "Dashboard (host)"]
    }
  ]
}

use Mix.Config

# Target config for RPi
# Used even for RPi0 to set the main USB port to non-gadget mode, so that the touchscreen can send touch inputs!

config :nerves, :firmware, fwup_conf: "config/rpi/fwup.conf"

config :hello_nerves, :viewport, %{
  name: :main_viewport,
  # default_scene: {HelloNerves.Scene.Crosshair, nil},
  default_scene: {HelloNerves.Scene.Crosshair, nil},
  size: {1024, 600},
  opts: [scale: 1.0],
  drivers: [
    %{
      module: Scenic.Driver.Nerves.Rpi
    },
    %{
      module: Scenic.Driver.Nerves.Touch,
      opts: [
        device: "STMicroelectronics 7H Custom Human interface",
        calibration: {{1, 0, 0}, {1, 0, 0}}
      ]
    }
  ]
}

defmodule HelloNerves.MixProject do
  use Mix.Project

  @app :hello_nerves
  @version "0.1.0"
  @all_targets [:rpi, :rpi0, :rpi4, :x86_64]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {HelloNerves.Application, []},
      extra_applications: [:logger, :runtime_tools, :hackney]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Web UI
      {:hello_ui, path: "../hello_ui"},

      # Dependencies for all targets
      {:nerves, "~> 1.7.0", runtime: false},
      {:shoehorn, "~> 0.7.0"},
      {:ring_logger, "~> 0.8.1"},
      {:toolshed, "~> 0.2.13"},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11.3", targets: @all_targets},
      {:nerves_pack, "~> 0.4.0", targets: @all_targets},

      # Dependencies for specific targets
      {:nerves_system_rpi, "~> 1.13", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.13", runtime: false, targets: :rpi0},
      {:nerves_system_rpi4, "~> 1.13", runtime: false, targets: :rpi4},
      {:nerves_system_x86_64, "~> 1.13", runtime: false, targets: :x86_64},

      # UI and Touch with Scenic
      {:scenic, "~> 0.10"},
      {:scenic_sensor, "~> 0.7"},
      {:scenic_driver_nerves_rpi, "~> 0.10", targets: @all_targets},
      {:scenic_driver_nerves_touch, "~> 0.10", targets: @all_targets},

      # Host only, local UI testing:
      {:scenic_driver_glfw, "~> 0.10", targets: :host},

      # Application specific libraries
      {:tesla, "~> 1.4.0"},
      {:hackney, "~> 1.10"},
      {:jason, ">= 1.0.0"}
    ]
  end

  def release do
    [
      overwrite: true,
      # Erlang distribution is not started automatically.
      # See https://hexdocs.pm/nerves_pack/readme.html#erlang-distribution
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end
end

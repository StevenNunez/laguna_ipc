defmodule LagunaIpc.MixProject do
  use Mix.Project

  def project do
    [
      app: :laguna_ipc,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {LagunaIpc.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:jason, ">= 0.0.0"},
      {:protobuf, "~> 0.5.3"},
      {:google_protos, "~> 0.1"},
    ]
  end
end

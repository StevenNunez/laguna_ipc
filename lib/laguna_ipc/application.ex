defmodule LagunaIpc.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
       {LagunaIpc.MessageStore, []}
    ]

    opts = [strategy: :one_for_one, name: LagunaIpc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule ChessClub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ChessClub.Repo,
      # Start the Telemetry supervisor
      ChessClubWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ChessClub.PubSub},
      # Start the Endpoint (http/https)
      ChessClubWeb.Endpoint,
      {Absinthe.Subscription, ChessClubWeb.Endpoint},
      {ChessClub.Chess.Game, name: ChessClub.Chess.Game}
      # Start a worker by calling: ChessClub.Worker.start_link(arg)
      # {ChessClub.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChessClub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChessClubWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

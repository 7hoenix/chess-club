# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

port = 4000

config :chess_club,
  ecto_repos: [ChessClub.Repo],
  port: port

# Configures the endpoint
config :chess_club, ChessClubWeb.Endpoint,
  http: [port: port],
  url: [host: "localhost"],
  secret_key_base: "AzWgyxx56tlcU7NWss7Dg5GWQvV9sBBVHoXVRIHsNQEzlf9Q6AdJwiF4TnWXn7v0",
  render_errors: [view: ChessClubWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ChessClub.PubSub,
  live_view: [signing_salt: "Y60neo5S"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

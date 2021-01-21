defmodule ChessClubWeb.Router do
  use ChessClubWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # NOTE: This :auth pipeline is for authenticating and does NOT mean that the underlying resource is authenticated.
  # For routes that are authenticated use the :ensure_auth pipeline instead.
  pipeline :auth do
    plug ChessClub.UserManager.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  # LOGIN and LOGOUT
  scope "/", ChessClubWeb do
    pipe_through [:browser, :auth]

    # get "/", PageController, :index

    get "/login", SessionController, :new
    post "/login", SessionController, :login
    get "/logout", SessionController, :logout
  end

  # Added for use while troubleshooting
  scope "/version", ChessClubWeb do
    get "/", VersionController, :index
  end

  scope "/", ChessClubWeb do
    pipe_through [:browser, :auth, :ensure_auth]

    get "/app", PageController, :index
  end

  scope "/api" do
    pipe_through :api

    forward "/graphical", Absinthe.Plug.GraphiQL,
      schema: ChessClubWeb.Schema,
      interface: :playground,
      context: %{pubsub: ChessClubWeb.Endpoint}

    forward "/graphql", Absinthe.Plug, schema: ChessClubWeb.Schema
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChessClubWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ChessClubWeb.Telemetry
    end
  end
end

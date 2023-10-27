defmodule NumbersWeb.Router do
  use NumbersWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NumbersWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_user_uuid
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NumbersWeb do
    pipe_through [:browser]

    live "/", GameLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", NumbersWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:numbers, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: NumbersWeb.Telemetry
    end
  end

  defp fetch_user_uuid(conn, _) do
    if user_uuid = get_session(conn, :user_uuid) do
      assign(conn, :user_uuid, user_uuid)
    else
      new_uuid = Ecto.UUID.generate()

      conn
      |> assign(:user_uuid, new_uuid)
      |> put_session(:user_uuid, new_uuid)
    end
  end
end

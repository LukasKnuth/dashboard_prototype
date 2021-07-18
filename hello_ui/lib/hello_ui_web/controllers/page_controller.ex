defmodule HelloUiWeb.PageController do
  use HelloUiWeb, :controller
  require Logger

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def trigger(conn, _params) do
    res = GenServer.call(:interaction_server, :trigger)
    # todo 1. build new dependency for both projects 2. add client, server and behaviour 3. use client here, run server in firmware, implement and pass behaviour to server
    Logger.info("Received #{inspect(res)} from GenServer")
    conn
    |> put_flash(:info, "Action was triggered!")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end

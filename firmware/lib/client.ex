defmodule Client do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://codeisland.org")
  plug(Tesla.Middleware.JSON)

  def inline do
    get("/api/inline.json")
  end
end

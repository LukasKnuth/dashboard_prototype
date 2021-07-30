defmodule Hue.Client do
  use Tesla

  alias Hue.{Group, Light}

  @bridge_ip "192.168.178.27"
  @user_name "6E8WkUgDB1PTrnaD1nMmdRbLMwWrid49NVsZrHYJ"

  plug(Tesla.Middleware.BaseUrl, "http://#{@bridge_ip}/api/#{@user_name}")
  plug(Tesla.Middleware.JSON)

  def groups do
    get("/groups")
  end

  def group_on(id, set_on) do
    put("/groups/#{id}/action", %{on: set_on})
  end

  def scenes do
    get("/scenes")
  end

  def scene_recall(group_id, scene_id) do
    put("/groups/#{group_id}/action", %{scene: scene_id})
  end

  def lights do
    get("/lights")
  end

  def light_on(id, set_on) do
    put("/lights/#{id}/state", %{on: set_on})
  end

  @type refreshable_item :: %Group{} | %Light{}
  @spec refresh(refreshable_item()) :: {:ok, refreshable_item()} | {:error, any()}
  def refresh(item)

  def refresh(%Group{id: id}) do
    with {:ok, %{body: body}} <- get("/groups/#{id}") do
      {:ok, Group.from_response(id, body)}
    end
  end

  def refresh(%Light{id: id}) do
    with {:ok, %{body: body}} <- get("/lights/#{id}") do
      {:ok, Light.from_response(id, body)}
    end
  end
end

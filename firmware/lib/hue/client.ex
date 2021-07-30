defmodule Hue.Client do
  use Tesla

  alias Hue.{Group, Light}

  # todo how can this be tested? Keep this requests only mock completely? or can we write MockAdapter?

  @bridge_ip "192.168.178.27"
  @user_name "6E8WkUgDB1PTrnaD1nMmdRbLMwWrid49NVsZrHYJ"

  plug(Tesla.Middleware.BaseUrl, "http://#{@bridge_ip}/api/#{@user_name}")
  plug(Tesla.Middleware.JSON)

  def groups do
    get("/groups")
  end

  def group(id) do
    get("/groups/#{id}")
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

  def light(id) do
    get("/lights/#{id}")
  end

  def light_on(id, set_on) do
    put("/lights/#{id}/state", %{on: set_on})
  end

  @type toggleable_item :: %Group{} | %Light{}
  @spec toggle(toggleable_item()) :: {:ok, toggleable_item()} | {:error, any()}
  def toggle(item)

  def toggle(%Light{id: id, is_on?: state}) do
    with {:ok, _} <- light_on(id, !state),
         {:ok, %{body: body}} <- light(id) do
      {:ok, Light.from_response(id, body)}
    end
  end

  def toggle(%Group{id: id, all_on?: state}) do
    with {:ok, _} <- group_on(id, !state),
         {:ok, %{body: body}} <- group(id) do
      {:ok, Group.from_response(id, body)}
    end
  end

  @type refreshable_item :: %Group{} | %Light{}
  @spec refresh(refreshable_item()) :: {:ok, refreshable_item()} | {:error, any()}
  def refresh(item)

  def refresh(%Group{id: id}) do
    with {:ok, %{body: body}} <- group(id) do
      {:ok, Group.from_response(id, body)}
    end
  end

  def refresh(%Light{id: id}) do
    with {:ok, %{body: body}} <- light(id) do
      {:ok, Light.from_response(id, body)}
    end
  end
end

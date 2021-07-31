defmodule Hue.Light do
  @doc """
  A single light.
  """

  defstruct [:id, :uid, :name, :is_on?, :brightness]

  def from_response(id, info) do
    %__MODULE__{
      id: id,
      uid: info["uniqueid"],
      name: info["name"],
      is_on?: info["state"]["on"],
      brightness: info["state"]["bri"]
    }
  end
end

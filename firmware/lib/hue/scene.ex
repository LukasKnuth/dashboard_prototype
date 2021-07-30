defmodule Hue.Scene do
  @doc """
  A configuration for multiple lights in any type of Group.
  """

  defstruct [:id, :name]

  def from_response(id, info) do
    %__MODULE__{
      id: id,
      name: info["name"]
    }
  end
end

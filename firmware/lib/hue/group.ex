defmodule Hue.Group do
  @doc """
  A bunch of lights grouped together.
  """

  defstruct [:id, :name, :all_on?, :any_on?]

  def from_response(id, info) do
    %__MODULE__{
      id: id,
      name: info["name"],
      all_on?: info["state"]["all_on"],
      any_on?: info["state"]["any_on"]
    }
  end
end

defmodule Usic.Resource.DeleteAny do
  require Logger
  alias Usic.Resource.State

  def delete(model, %State{resp: instance} = state) do
    case Usic.Repo.delete(instance) do
      {:ok, _} -> 
        state
      {:error, reason} -> 
        struct(state, error: reason)
    end
  end
end

defimpl Usic.Resource.Delete, for: Any do
  use Usic.Resource
  stage :handle, mod: Usic.Resource.Read
  stage :delete, mod: Usic.Resource.DeleteAny
end

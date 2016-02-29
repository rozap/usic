defmodule Usic.Resource.DeleteAny do
  require Logger
  alias Usic.Resource.State
  alias Usic.Resource.Read

  def handle(model, state) do
    with {:ok, %State{resp: instance}} <- Read.read(model, state) do
      case Usic.Repo.delete(instance) do
        {:ok, _} -> state
        {:error, reason} -> struct(state, error: reason)
      end
    end
  end
end

defimpl Usic.Resource.Delete, for: Any do
  defdelegate handle(model, state), to: Usic.Resource.DeleteAny
end

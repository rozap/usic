defmodule Usic.Resource.UpdateAny do
  alias Usic.Resource.State
  alias Usic.Resource.Read

  def handle(model, %State{params: params, socket: socket} = state) do
    case Read.handle(model, state) do
      %State{resp: instance} ->
        session = Map.get(socket.assigns, :session, nil)
        cset = model.__struct__.changeset(
          instance,
          params,
          session: session
        )
        case Usic.Repo.update(cset) do
          {:ok, _} -> Read.handle(model, state)
          {:error, reason} -> struct(state, error: reason)
        end
      err -> err
    end
  end  
end

defimpl Usic.Resource.Update, for: Any do
  defdelegate handle(model, state), to: Usic.Resource.UpdateAny
end

defmodule Usic.Resource.UpdateAny do
  alias Usic.Resource.State
  alias Usic.Resource.Read

  def update(model, %State{params: params, socket: socket} = state) do
    case Read.handle(model, state) do
      %State{resp: instance} ->
        session = Map.get(socket.assigns, :session, nil)
        cset = model.__struct__.changeset(
          instance,
          params
        )
        case Usic.Repo.update(cset) do
          {:ok, _} -> state
          {:error, reason} -> struct(state, error: reason)
        end
      err -> err
    end
  end  
end

defimpl Usic.Resource.Update, for: Any do
  use Usic.Resource
  stage :update, mod: Usic.Resource.UpdateAny
  stage :handle, mod: Usic.Resource.Read

end
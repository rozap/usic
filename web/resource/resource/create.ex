
defmodule Usic.Resource.CreateAny do
  require Logger
  alias Usic.Resource.State
  alias Usic.Resource.Read

  def handle(model, %State{params: params, socket: socket} = state) do
    session = Map.get(socket.assigns, :session, nil)
    cset = model.__struct__.changeset(model, params, session: session)
    Logger.info("Create #{inspect model} :: #{inspect params}")

    case Usic.Repo.insert(cset) do
      {:error, reason} ->
        struct(state, error: reason)
      {:ok, inserted} ->
        Read.handle(model, struct(state, params: %{"id" => inserted.id}))
    end
  end
end

defimpl Usic.Resource.Create, for: Any do
  defdelegate handle(model, state), to: Usic.Resource.CreateAny
end

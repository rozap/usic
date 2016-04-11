defmodule Usic.Resource.CreateAny do
  require Logger
  alias Usic.Resource.State
  alias Usic.Resource.Read
  alias Ecto.Changeset

  def create(model, %State{params: params, socket: socket} = state) do
    session = Map.get(socket.assigns, :session, nil)
    cset = model.__struct__.changeset(model, params)
    Logger.info("Create #{inspect model} :: #{inspect params}")

    case Usic.Repo.push_insert(cset) do
      {:error, %Changeset{errors: errors} = cset} ->
        errors = Usic.Resource.Helpers.format_cset_errors(errors)
        struct(state, error: errors)
      {:error, reason} ->
        struct(state, error: reason)
      {:ok, inserted} ->
        struct(state, resp: inserted, params: %{"id" => inserted.id})
    end
  end
end

defimpl Usic.Resource.Create, for: Any do
  use Usic.Resource
  stage :create, mod: Usic.Resource.CreateAny
end

defmodule Usic.Resource.Session do
  require Logger
  import Phoenix.Socket
  import Ecto.Query
  alias Usic.Session
  alias Usic.Repo
  import Usic.Resource.Helpers
  alias Usic.Resource.State


  defimpl Usic.Resource.Create, for: Session do
    def handle(model, %State{params: params, socket: socket} = state) do
      cset = Session.changeset(model, params)
      if cset.valid? do
        case Repo.insert(cset) do
          {:error, reason} -> struct(state, error: reason)
          {:ok, session} ->
            session = Repo.one(from s in Session,
              where: s.id == ^session.id,
              preload: [:user])
            Logger.info("#{session.user.email} has signed in")

            socket = assign(socket, :session, session)
            struct(state, resp: session, socket: socket)
        end
      else
        struct(state, error: format_cset_errors(cset.errors))
      end
    end
  end

  defimpl Usic.Resource.Read, for: Session do
    def handle(_, %State{socket: socket} = state) do
      with_session state do
        struct(state, resp: socket.assigns.session)
      end
    end
  end


  defimpl Usic.Resource.Delete, for: Session do
    def handle(_, %State{socket: socket} = state) do
      with_session state do
        case Repo.delete(socket.assigns.session) do
          {:ok, _} -> 
            socket = assign(socket, :session, nil)
            struct(state, socket: socket)
          {:error, cset} ->
            struct(state, error: format_cset_errors(cset))
        end
      end
    end
  end


end
defmodule Usic.Resource.Session do
  require Logger
  import Phoenix.Socket
  import Ecto.Query
  alias Usic.Session
  alias Usic.Repo
  alias Ecto.Changeset
  import Usic.Resource.Helpers
  alias Usic.Resource.State

  def get_socket_session(token, socket) do
    result = Repo.one(
      from s in Session,
      where: s.token == ^token, 
      select: s, 
      preload: [:user]
    )
    case result do
      nil -> 
        Logger.warn("invalid session token #{token}")
        socket
      session ->
        Logger.info("#{session.user.email} has signed in")
        assign(socket, :session, session)
    end
  end


  defimpl Usic.Resource.Create, for: Session do
    use Usic.Resource

    stage :create, mod: Usic.Resource.CreateAny
    stage :put_session_in_socket


    def put_session_in_socket(_, %State{resp: inserted, socket: socket} = state) do
      token = inserted.token
      socket = Usic.Resource.Session.get_socket_session(token, socket)
      struct(state, socket: socket)
    end
  end

  defimpl Usic.Resource.Read, for: Session do
    def handle(_, %State{socket: socket} = state) do
      with_session state do
        struct(state, resp: socket.assigns.session)
      end
    end
  end


  # defimpl Usic.Resource.Delete, for: Session do
  #   def handle(_, %State{socket: socket} = state) do
  #     with_session state do
  #       case Repo.delete(socket.assigns.session) do
  #         {:ok, _} -> 
  #           socket = assign(socket, :session, nil)
  #           struct(state, socket: socket)
  #         {:error, cset} ->
  #           struct(state, error: format_cset_errors(cset))
  #       end
  #     end
  #   end
  # end


end
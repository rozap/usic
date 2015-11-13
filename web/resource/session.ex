defmodule Usic.Resource.Session do
  require Logger
  import Phoenix.Socket
  import Ecto.Query
  import Ecto.Model
  alias Usic.Session
  alias Usic.User
  alias Usic.Repo

  def create(model, params, socket) do
    case Usic.Resource.create(model, params, socket) do
      {{:error, _}, _} = r -> r
      {{:ok, session}, socket} ->

        session = Repo.one(from s in Session,
          where: s.id == ^session.id,
          preload: [:user])
        Logger.info("#{session.user.email} has signed in")
        {{:ok, session}, assign(socket, :session, session)}
    end
  end

  def read(model, params, socket) do
    {{:ok, socket.assigns.session}, socket}
  end

end
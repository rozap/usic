defmodule Usic.Resource.Session do
  import Phoenix.Socket
  import Ecto.Query
  import Ecto.Model
  alias Usic.Session
  alias Usic.User
  alias Usic.Repo

  def create(model, params, socket) do
    case Usic.Resource.create(model, params, socket) do
      {{:error, reason}, _} = r -> r
      {{:ok, session}, socket} ->

        session = Repo.one(from s in Session,
          where: s.id == ^session.id,
          preload: [:user])

        {{:ok, session}, assign(socket, :session, session)}
    end
  end

  def list(model, params, socket) do
    Usic.Resource.list(model, params, socket)
  end

end
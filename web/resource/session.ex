defmodule Usic.Resource.Session do
  require Logger
  import Phoenix.Socket
  import Ecto.Query
  alias Usic.Session
  alias Usic.Repo
  alias Usic.Resource.Helpers
  import Usic.Resource.Helpers


  defimpl Usic.Resource.Create, for: Session do
    def create(model, params, socket) do
      cset = Session.changeset(model, params)
      if cset.valid? do
        case Repo.insert(cset) do
          {:error, r} -> {:error, r}
          {:ok, session} ->
            session = Repo.one(from s in Session,
              where: s.id == ^session.id,
              preload: [:user])
            Logger.info("#{session.user.email} has signed in")
            {:ok, {session, assign(socket, :session, session)}}
        end
      else
        {:error, {format_cset_errors(cset.errors), socket}}
      end
    end
  end

  defimpl Usic.Resource.Read, for: Session do
    def read(_, _, socket) do
      with_session socket do
        {:ok, {socket.assigns.session, socket}}
      end
    end
  end


  defimpl Usic.Resource.Delete, for: Session do
    def delete(_, _, socket) do
      with_session socket do
        case Repo.delete(socket.assigns.session) do
          {:ok, _} -> {:ok, {%{}, socket}}
          {:error, cset} ->
            errs = R.format_cset_errors(cset)
            {:error, {errs, socket}}
        end
      end
    end
  end


end
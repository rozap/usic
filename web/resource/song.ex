defmodule Usic.Resource.Song do
  import Ecto.Query
  require Logger
  import Usic.Resource.Helpers
  alias Usic.Loader
  alias Usic.Song
  alias Usic.Model.Dispatcher
  alias Usic.Resource.State


  def join_user do
    from(m in Song,
      left_join: u in assoc(m, :user),
      preload: [user: u])
  end

  defimpl Usic.Resource.Create, for: Song do
    defp begin_download!(%State{resp: song, error: nil, socket: socket}) do
      Dispatcher.bind(song, socket)
      Loader.get_song(song)
    end
    defp begin_download!(state), do: state

    def handle(_, state) do
      result = Usic.Resource.CreateAny.handle(%Song{}, state)
      |> begin_download!


      case result do
        {:ok, song} ->
          r = Usic.Resource.Song.join_user
          |> as_single_result_for(%Song{}, %{"id" => song.id}, state)
        {:error, reason} -> struct(state, error: reason)
      end
    end
  end

  defimpl Usic.Resource.List, for: Song do
    def handle(_, %State{params: params} = state) do
      Usic.Resource.Song.join_user
      |> slice(params)
      |> select([m], m)
      |> as_list_result_for(%Song{}, state)
    end
  end

  defimpl Usic.Resource.Read, for: Song do
    def handle(_, %State{params: params} = state) do
      Usic.Resource.Song.join_user
      |> as_single_result_for(%Song{}, params, state)
    end
  end

  defimpl Usic.Resource.Delete, for: Song do
    def handle(_, %State{params: params, socket: socket} = state) do
      case socket.assigns[:session] do
        nil -> 
          struct(state, error: %{"session" => "song_update_not_allowed"})
        session ->
          song = Usic.Repo.get(Song, params["id"])
          case Song.check_user_perms(song, session) do
            [] -> 
              Usic.Repo.delete(song)
              struct(state, resp: %{})
            reason -> struct(state, error: reason)
          end
      end
    end
  end
end
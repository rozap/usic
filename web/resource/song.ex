defmodule Usic.Resource.Song do
  import Ecto.Query
  require Logger
  import Usic.Resource.Helpers
  alias Usic.Resource.Helpers
  alias Usic.Loader
  alias Usic.User
  alias Usic.Song
  alias Usic.Model.Dispatcher



  def join_user do
    from(m in Song,
      left_join: u in assoc(m, :user),
      preload: [user: u])
  end

  defimpl Usic.Resource.Create, for: Song do
    defp begin_download!({:ok, {song, socket}}) do
      Dispatcher.bind(song, socket)
      Loader.get_song(song)
    end
    defp begin_download!({:error, {reason, _}} = r), do: {:error, reason}

    def create(_, params, socket) do
      result = Helpers.create(%Song{}, params, socket)
      |> begin_download!

      case result do
        {:ok, song} ->
          r = Usic.Resource.Song.join_user
          |> as_single_result_for(%Song{}, %{"id" => song.id}, socket)

        {:error, reason} ->
          {:error, {reason, socket}}
      end
    end
  end

  defimpl Usic.Resource.List, for: Song do
    def list(_, params, socket) do
      Usic.Resource.Song.join_user
      |> slice(params)
      |> select([m], m)
      |> as_list_result_for(%Song{}, params, socket)
    end
  end

  defimpl Usic.Resource.Read, for: Song do
    def read(_, params, socket) do
      Usic.Resource.Song.join_user
      |> as_single_result_for(%Song{}, params, socket)
    end
  end


end
defmodule Usic.Resource.Song do
  require Logger
  import Phoenix.Socket
  import Ecto.Query
  import Ecto.Model
  alias Usic.Song
  alias Usic.User
  alias Usic.Repo

  @songtopic "create:song:success"

  defp fetch_song(url, uid) do
    case Loader.get_song_id(url) do
      {:ok, id} ->

        Usic.SongServer.get(location, uid)

        push socket, "create:song:success", %{
          status: :ok,
          response: %{

          }
        }
      {:error, _} ->
        {:error, %{"url" => "invalid_url"}}
    end

  end


  def create(model, params, socket) do
    uid = UUID.uuid4()

    song = Usic.Resource.create(model, params, socket)

    case params["url"] do
      nil -> {{:error, %{"url" => "url_required"}, socket}
      url ->
        push socket, @songtopic, %{
          status: :ok,
          response: song
        }
        fetch_song(url, uid)
    end

    {{:ok, song}, socket}
  end


end
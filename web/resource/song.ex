defmodule Usic.Resource.Song do
  require Logger
  alias Usic.Loader
  alias Usic.Model.Dispatcher

  @songtopic "create:song:success"


  def begin_download({:ok, {song, socket}}) do
    Dispatcher.bind(song, socket)
    Loader.get_song(song)
  end

  def begin_download({:error, _} = r), do: r


  def create(model, params, socket) do
    result = model
    |> Usic.Resource.create(params, socket)

    begin_download(result)

    result
  end


end
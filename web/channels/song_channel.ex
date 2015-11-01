defmodule Usic.SongChannel do
  use Phoenix.Channel

  alias Usic.Loader

  @search "search"
  @topic_prefix "song:"

  def join(@topic_prefix <> uid, message, socket) do
    IO.puts "Joined #{inspect uid}"
    {:ok, socket}
  end

  def handle_in(@search, %{"term" => location}, socket) do
    case Loader.get_song_id(location) do
      {:ok, _id} ->
        @topic_prefix <> uid = socket.topic
        Usic.SongServer.get(location, uid)
        {:reply, {:ok, %{event: @search, state: "loading", message: "getting_song"}}, socket}
      {:error, _} ->
        {:reply, {:ok, %{event: @search, state: "error", message: "invalid_youtube"}}, socket}
    end
  end

  def handle_in(message, payload, socket) do
    IO.puts "Invalid #{message} #{inspect payload}"
    {:noreply, socket}
  end

  def terminate(reason, socket) do
    @topic_prefix <> uid = socket.topic
    Loader.unload(uid)
  end


  def handle_info({:get_song, {:ok, location}}, socket) do
    push socket, @search, %{status: :ok, response: %{
      state: "success",
      message: "video_retrieved",
      location: location,
      event: "search"
    }}
    {:noreply, socket}
  end

  def handle_info({:get_song, {:error, reason}}, socket) do
    push socket, @search, %{status: :ok, response: %{
      state: "error",
      message: "download_failed",
      reason: reason
    }}
    {:noreply, socket}
  end

end
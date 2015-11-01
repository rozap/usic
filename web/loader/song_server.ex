defmodule Usic.SongServer do
  use GenServer
  ##
  # Will deal with throttling of song requests so shit
  # doesn't hit the fan
  #

  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init(args) do
    {:ok, %{}}
  end

  def handle_cast({:get, location, uid, channel}, state) do

    Task.start_link(fn ->
      result = Usic.Loader.get_song(uid, location)
      send channel, {:get_song, result}
    end)

    {:noreply, state}
  end


  def get(location, uid) do
    GenServer.cast(__MODULE__, {:get, location, uid, self})
  end
end
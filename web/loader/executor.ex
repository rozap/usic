defmodule Usic.Executor do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init(_args) do
    {:ok, %{}}
  end

  def handle_call({:get, url, output_loc}, _from, state) do
    response = System.cmd("youtube-dl", [
      "--extract-audio",
      "--audio-format", "best",
      "--audio-quality", "0",
      url,
      "-o",
      output_loc
    ])
    {:reply, response, state}
  end

  def get(url, output_loc) do
    try do
      GenServer.call(__MODULE__, {:get, url, output_loc}, 15_000)
    catch
      :exit, _ -> {:error, "upstream_timeout"}
    end
  end

end


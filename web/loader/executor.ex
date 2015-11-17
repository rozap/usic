defmodule Usic.Executor do
  use GenServer
  require Logger
  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init(_args) do
    {:ok, %{}}
  end

  def handle_call({:get, url, output_loc}, _from, state) do
    args = [
      "--extract-audio",
      "--audio-format", "best",
      "--audio-quality", "0",
      url,
      "-o",
      output_loc
    ]

    ll = Enum.join(args, " ")
    Logger.info("[youtube-dl] #{ll}")

    response = System.cmd("youtube-dl", args)
    {:reply, response, state}
  end

  def get(url, output_loc) do
    try do
      GenServer.call(__MODULE__, {:get, url, output_loc}, 30_000)
    catch
      :exit, _ ->
        Logger.warn("[youtube-dl] timeout from python process")
        {:error, "upstream_timeout"}
    end
  end

end


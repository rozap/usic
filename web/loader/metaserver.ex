defmodule Usic.Metaserver do
  use GenServer
  require Logger
  alias Usic.Loader.Metadata

  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init(_args) do
    {:ok, %{}}
  end

  def handle_call({:get, id}, _from, state) do
    Metadata.start
    result = case Metadata.get(id) do
      {:ok, resp} -> {:ok, resp.body}
      err -> err
    end
    {:reply, result, state}
  end

  def get(id) do
    try do
      GenServer.call(__MODULE__, {:get, id}, 30_000)
    catch
      :exit, _ ->
        Logger.warn("[metaserver] timeout from meta server process")
        {:error, "upstream_timeout"}
    end
  end

end


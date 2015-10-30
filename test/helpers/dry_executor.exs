defmodule Usic.DryExecutor do
  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init(args) do
    {:ok, %{}}
  end

  def handle_call({:get, url, output_loc}, _from, state) do
    [_, id] = String.split(url, "=")
    response = if String.length(id) < 6 do
      {"invalid id", 1}
    else
      {"ok done", 0}
    end
    {:reply, response, state}
  end

  def get(url, output_loc) do
    GenServer.call(__MODULE__, {:get, url, output_loc})
  end

end
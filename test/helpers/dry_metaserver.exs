defmodule Usic.DryMetaserver do
  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init(_args) do
    {:ok, %{}}
  end

  def handle_call({:get, _id}, _from, state) do
    metadata = %{
      "title" => "foobar"
    }
    {:reply, {:ok, metadata}, state}
  end

  def get(id) do
    GenServer.call(__MODULE__, {:get, id})
  end

end
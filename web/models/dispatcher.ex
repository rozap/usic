defmodule Usic.Model.Dispatcher do
  use GenServer
  require Logger
  import Phoenix.Channel
  import Phoenix.Socket

  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init(_args) do
    {:ok, %{}}
  end

  def model_key(model) do
    model.__struct__
    |> Atom.to_string
    |> String.split(".")
    |> List.last
    |> String.downcase
  end

  def handle_call({:bind, model, socket}, _from, state) do
    mkey = model_key(model)
    state = case state[mkey] do
      nil -> put_in(state, [mkey], %{})
      _ -> state
    end
    socks = get_in(state, [mkey, model.id]) || []
    state = put_in(state, [mkey, model.id], [socket | socks])
    {:reply, :ok, state}
  end

  def handle_cast({:after_insert, cset}, state) do
    {:noreply, state}
  end

  def handle_cast({:after_update, cset}, state) do
    mkey = model_key(cset.model)
    case get_in(state, [mkey, cset.model.id]) do
      nil -> :ok
      sockets ->
        Enum.each(sockets, fn socket ->
          push socket, "update:#{mkey}", cset.model
        end)
    end
    {:noreply, state}
  end


  def after_insert(cset) do
    GenServer.cast(__MODULE__, {:after_insert, cset})
    cset
  end

  def after_update(cset) do
    GenServer.cast(__MODULE__, {:after_update, cset})
    cset
  end

  def bind(model, socket) do
    GenServer.call(__MODULE__, {:bind, model, socket})
  end

  def unbind(socket) do
    GenServer.call(__MODULE__, {:unbind, socket})
  end
end
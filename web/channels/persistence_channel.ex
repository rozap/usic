defmodule Usic.PersistenceChannel do
  use Phoenix.Channel
  require Logger
  require Usic.Song
  alias Usic.Resource.State

  @create "create"
  @update "update"
  @delete "delete"
  @read   "read"
  @list   "list"

  @creatable %{
    "user" => %Usic.User{},
    "song" => %Usic.Song{},
    "session" => %Usic.Session{},
    "region" => %Usic.Region{}
  }

  @listable %{
    "song" => %Usic.Song{},
    "region" => %Usic.Region{}
  }

  @readable %{
    "session" => %Usic.Session{},
    "song" => %Usic.Song{},
    "region" => %Usic.Region{}
  }

  @updatable %{
    "song" => %Usic.Song{},
    "region" => %Usic.Region{},
    "user" => %Usic.User{}
  }

  @deletable %{
    "region" => %Usic.Region{},
    "session" => %Usic.Session{},
    "song" => %Usic.Song{}
  }

  @operations [
    {@create, Usic.Resource.Create, quote do: @creatable},
    {@list, Usic.Resource.List,     quote do: @listable},
    {@read, Usic.Resource.Read,     quote do: @readable},
    {@update, Usic.Resource.Update, quote do: @updatable},
    {@delete, Usic.Resource.Delete, quote do: @deletable}
  ]


  def join("session", _, socket) do
    Logger.info("Anon session has started")
    {:ok, socket}
  end

  def join("session:" <> session_token, _message, socket) do
    {:ok, Usic.Resource.Session.get_socket_session(session_token, socket)}
  end

  def join(invalid, _, _) do
    Logger.warn("Invalid session join #{invalid}")
    {:error, %{error: :invalid_handshake}}
  end


  defp r(%State{resp: nil, socket: socket, error: nil}) do
    {:reply, {:ok, %{}}, socket}
  end
  defp r(%State{resp: resp, socket: socket, error: nil}) do
    {:reply, {:ok, resp}, socket}
  end
  defp r(%State{socket: socket, error: reason}) do
    {:reply, {:error, reason}, socket}
  end


  Enum.each(@operations, fn {verb, protocol, noun} ->
    def handle_in(unquote(verb) <> ":" <> name, params, socket) do
      case Dict.get(unquote(noun), name) do
        nil ->
          Logger.error("Invalid resource #{unquote(verb) <> ":" <> name} #{inspect unquote(noun)}")
          %State{error: %{message: "invalid_resource"}, socket: socket}
          |> r
        model ->
          state = %State{params: params, socket: socket}
          Logger.debug("Dispatch #{unquote(protocol)} #{inspect model.__struct__} #{inspect state}")
          res = unquote(protocol).handle(model, state)
          Logger.debug("#{inspect res}")
          r(res)
      end
    end
  end)


  def handle_info(_, socket) do
    {:noreply, socket}
  end

  def terminate(_reason, _socket) do
    :ok
  end
end
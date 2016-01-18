defmodule Usic.PersistenceChannel do
  use Phoenix.Channel
  import Ecto.Query
  require Logger
  alias Usic.Session
  alias Usic.Repo
  require Usic.Song

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
    {@list, Usic.Resource.List,   quote do: @listable},
    {@read, Usic.Resource.Read,   quote do: @readable},
    {@update, Usic.Resource.Update, quote do: @updatable},
    {@delete, Usic.Resource.Delete, quote do: @deletable}
  ]


  def join("session", _, socket) do
    Logger.info("Anon session has started")
    {:ok, socket}
  end

  def join("session:" <> session_token, _message, socket) do
    case Repo.one(from s in Session,
      where: s.token == ^session_token, select: s, preload: [:user]) do
      nil -> {:error, %{error: :invalid_token}}
      session ->
        Logger.info("#{session.user.email} has started an existing session")
        {:ok, assign(socket, :session, session)}
    end
  end

  def join(invalid, _, _) do
    Logger.warn("Invalid session join #{invalid}")
    {:error, %{error: :invalid_handshake}}
  end

  defp r({:error, {reason, socket}}) do
    {:reply, {:error, reason}, socket}
  end

  defp r({:ok, {resp, socket}}) do
    {:reply, {:ok, resp}, socket}
  end

  Enum.each(@operations, fn {verb, protocol, noun} ->
    def handle_in(unquote(verb) <> ":" <> name, payload, socket) do
      case Dict.get(unquote(noun), name) do
        nil ->
          Logger.error("Invalid resource #{unquote(verb) <> ":" <> name} #{inspect unquote(noun)}")
          r({:error, {%{message: "invalid_resource"}, socket}})
        model ->
          r(apply(unquote(protocol), String.to_atom(unquote(verb)), [model, payload, socket]))
      end
    end
  end)


  def handle_info(info, socket) do
    {:noreply, socket}
  end

  def terminate(_reason, _socket) do
    :ok
  end
end
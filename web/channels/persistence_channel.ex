defmodule Usic.PersistenceChannel do
  use Phoenix.Channel
  import Ecto.Query
  require Logger
  alias Usic.Session
  alias Usic.Repo

  @create "create"
  @update "update"
  @delete "delete"
  @read   "read"
  @list   "list"

  @creatable %{
    "user" => {Usic.User, Usic.Resource},
    "song" => {Usic.Song, Usic.Resource},
    "session" => {Usic.Session, Usic.Resource.Session}
  }

  @listable %{
    "song" => {Usic.Song, Usic.Resource}
  }

  @readable %{
    "session" => {Usic.Session, Usic.Resource.Session}
  }

  @operations [
    {@create, quote do: @creatable},
    {@list, quote do: @listable},
    {@read, quote do: @readable}
  ]


  def join("anon", message, socket) do
    Logger.info("Anon session has started")
    {:ok, socket}
  end

  def join(session_token, message, socket) do
    case Repo.one(from s in Session,
      where: s.token == ^session_token, select: s, preload: [:user]) do
      nil -> {:error, %{error: :invalid_token}}
      session ->
        Logger.info("#{session.user.email} has started an existing session")
        {:ok, assign(socket, :session, session)}
    end
  end



  def join(invalid, _, socket) do
    Logger.info("Invalid session join #{invalid}")
    {:error, %{error: :invalid_handshake}}
  end


  defp r({{:error, reason}, socket}) do
    {:reply, {:error, reason}, socket}
  end

  defp r({{:ok, resp}, socket}) do
    {:reply, {:ok, resp}, socket}
  end

  Enum.each(@operations, fn {verb, noun} ->
    def handle_in(unquote(verb) <> ":" <> name, payload, socket) do
      case Dict.get(unquote(noun), name) do
        nil ->
          Logger.error("Invalid resource #{unquote(verb) <> ":" <> name} #{inspect unquote(noun)}")
          r({{:error, %{message: "invalid_resource"}}, socket})
        {model, res} ->
          r(apply(res, String.to_atom(unquote(verb)), [model, payload, socket]))
      end
    end
  end)

  def terminate(_reason, _socket) do
    :ok
  end
end
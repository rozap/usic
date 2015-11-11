defmodule Usic.PersistenceChannel do
  use Phoenix.Channel
  import Ecto.Query
  require Logger

  @create "create:"
  @update "update:"
  @delete "delete:"
  @read   "read:"
  @list   "list:"

  @creatable %{
    "user" => {Usic.User, Usic.Resource},
    "song" => {Usic.Song, Usic.Resource},
    "session" => {Usic.Session, Usic.Resource.Session}
  }

  @listable %{
    "song" => {Usic.Song, Usic.Resource}
  }

  def join(_term, _message, socket) do
    {:ok, socket}
  end

  defp r({{:error, reason}, socket}) do
    {:reply, {:error, reason}, socket}
  end

  defp r({{:ok, resp}, socket}) do
    {:reply, {:ok, resp}, socket}
  end

  def handle_in(@create <> name, payload, socket) do
    case Dict.get(@creatable, name) do
      nil ->
        r({{:error, %{message: "invalid_model"}}, socket})
      {model, res} ->
        r(res.create(model, payload, socket))
    end
  end

  def handle_in(@list <> name, payload, socket) do
    case Dict.get(@listable, name) do
      nil ->
        r({{:error, %{message: "invalid_model"}}, socket})
      {model, res} ->
        r(res.list(model, payload, socket))
    end
  end

  def terminate(_reason, _socket) do
    :ok
  end
end
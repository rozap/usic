defmodule Usic.PersistenceChannel do
  use Phoenix.Channel
  import Ecto.Query
  require Logger

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
    "user" => {Usic.User, Usic.Resource}
  }

  @operations [
    {@create, quote do: @creatable},
    {@list, quote do: @listable},
    {@read, quote do: @readable}
  ]

  def join(_term, _message, socket) do
    {:ok, socket}
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
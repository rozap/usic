defmodule Usic.PersistenceChannel do
  use Phoenix.Channel
  require Logger

  @create "create:"
  @update "update:"
  @delete "delete:"
  @read   "read:"
  @list   "list:"

  @creatable %{
    "user" => Usic.User,
    "song" => Usic.Song,
    "session" => Usic.Session
  }

  def join(_term, _message, socket) do
    {:ok, socket}
  end

  defp r(socket, {:error, reason}) do
    {:reply, {:error, reason}, socket}
  end

  defp r(socket, {:ok, resp}) do
    {:reply, {:ok, resp}, socket}
  end

  defp model_read(model, inserted) do
    model.readable(inserted)
  end

  ## wtf why
  defp format_cset_errors(errors) do
    errors
    |> Enum.map(
      fn {name, {msg, bindings}} ->
            message = Enum.reduce(bindings, msg, fn {k, v}, acc ->
              String.replace(acc, "%{#{k}}", "#{v}")
            end)
            {name, message}
         {name, value} -> {name, value}
    end)
    |> Enum.into(%{})
  end

  defp create(name, payload, socket) do
    Logger.info("Create #{name}")
    case Dict.get(@creatable, name) do
      nil ->
        {:error, %{message: "invalid_model"}}
      model ->
        user = Map.get(socket.assigns, :user, nil)
        cset = model.changeset(struct(model), payload, user: user)
        if cset.valid? do
          case Usic.Repo.insert(cset) do
            {:error, attempt} ->
              {:error, format_cset_errors(attempt.errors)}
            {:ok, inserted} ->
              {:ok, model_read(model, inserted)}
          end
        else
          {:error, format_cset_errors(cset.errors)}
        end
    end
  end



  def handle_in(@create <> name, payload, socket) do
    r(socket, create(name, payload, socket))
  end

  def terminate(_reason, _socket) do
    :ok
  end
end
defmodule Usic.Resource.User do
  require Logger
  import Phoenix.Socket
  import Ecto.Query
  import Ecto.Model
  alias Usic.User
  alias Usic.Repo

  def update(model, params, socket) do
    want_to_update = params["id"]
    case socket.assigns.session do
      %{user: %{id: ^want_to_update}} ->
        Usic.Resource.update(model, params, socket)
      _ ->
        if socket.assigns.session do
          Logger.warn("User #{socket.assigns.session.user.id} attempted to update #{want_to_update}")
        end
        {:error, {%{
          "id" => "unauthorized"
        }, socket}}
    end
  end

end
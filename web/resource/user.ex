defmodule Usic.Resource.User do
  require Logger
  alias Usic.User
  alias Usic.Resource.Helpers

  defimpl Usic.Resource.Update, for: User do
    def update(_, params, socket) do
      want_to_update = params["id"]
      case socket.assigns.session do
        %{user: %{id: ^want_to_update}} ->
          Helpers.update(%User{}, params, socket)
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
end
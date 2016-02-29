defmodule Usic.Resource.User do
  require Logger
  alias Usic.User
  alias Usic.Resource.State

  defimpl Usic.Resource.Update, for: User do
    def handle(_, %State{params: params, socket: socket} = state) do
      want_to_update = params["id"]
      case socket.assigns.session do
        %{user: %{id: ^want_to_update}} ->
          Logger.info("Update user")
          Usic.Resource.UpdateAny.handle(%User{}, state)
        _ ->
          Logger.info("Update user error")
          if socket.assigns.session do
            Logger.warn("User #{socket.assigns.session.user.id} attempted to update #{want_to_update}")
          end
          struct(state, error: %{"id" => "unauthorized"})
      end
    end
  end
end
defmodule Usic.Resource.User do
  require Logger
  alias Usic.User
  alias Usic.Resource.State


  defimpl Usic.Resource.Update, for: User do
    use Usic.Resource

    stage :validate
    stage :update, mod: Usic.Resource.UpdateAny
    stage :read, mod: Usic.Resource.ReadAny

    def validate(_, %State{params: params, socket: socket} = state) do
      want_to_update = params["id"]
      case socket.assigns.session do
        %{user: %{id: ^want_to_update}} ->
          Logger.info("Update user")
          state
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
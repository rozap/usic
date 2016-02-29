defmodule Usic.Resource.Region do
  require Logger
  alias Usic.Region
  alias Usic.Repo
  alias Usic.Resource.State

  defimpl Usic.Resource.Delete, for: Region do
    def handle(_, %State{params: params, socket: socket} = state) do
      case Repo.get(Region, params["id"]) do
        nil -> 
          struct(state, error: %{delete: :not_found})
        region ->
          session = Map.get(socket.assigns, :session, nil)
          case Region.check_user_perms(region.song_id, session) do
            [] ->
              Repo.delete(region)
              struct(state, resp: %{})
            errors ->
              struct(state, error: %{delete: Enum.into(errors, %{})})
          end
      end
    end
  end
end
defmodule Usic.Resource.Region do
  require Logger
  alias Usic.Region
  alias Usic.Resource.Helpers
  alias Usic.Repo

  defimpl Usic.Resource.Delete, for: Region do
    def delete(_, params, socket) do
      case Repo.get(Region, params["id"]) do
        nil -> {:error, {%{delete: :not_found}, socket}}
        region ->
          session = Map.get(socket.assigns, :session, nil)
          case Region.check_user_perms(region.song_id, session) do
            [] ->
              Helpers.do_delete(region, socket)
            errors ->
              {:error, {%{delete: Enum.into(errors, %{})}, socket}}
          end
      end
    end
  end
end
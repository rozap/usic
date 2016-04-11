defmodule Usic.Resource.Region do
  require Logger
  alias Usic.Region
  alias Usic.Repo
  alias Usic.Resource.State
  import Ecto.Query



  defp check_user_perms(song_id, session) do
    case Usic.Repo.get(Usic.Song, song_id) do
      nil -> 
        []
      song -> 
        Usic.Resource.Song.check_user_perms(song, session)
    end
  end

  def validate_user(_, %State{resp: region, socket: socket} = state) do
    session = get_in(socket.assigns, [:session])

    case check_user_perms(region.song_id, session) do
      []     -> state
      errors -> struct(state, error: errors)
    end
  end


  defimpl Usic.Resource.List, for: Region do
    use Usic.Resource

    stage :query
    stage :evaluate, mod: Usic.Resource.ListAny
    stage :meta,     mod: Usic.Resource.ListAny

    def query(model, %State{params: %{"where" => %{"meta.tags" => tags}}} = state) do
      %State{query: query} = Usic.Resource.ListAny.query(model, state)
      matching = query |> where([m], fragment("meta->'tags' @> ?", ^tags))
      struct(state, query: matching)
    end

    def query(model, state) do
      Usic.Resource.ListAny.query(model, state)
    end

  end


  defimpl Usic.Resource.Delete, for: Region do
    use Usic.Resource

    stage :handle, mod: Usic.Resource.Read
    stage :validate_user, mod: Usic.Resource.Region
    stage :delete, mod: Usic.Resource.DeleteAny
  end
end
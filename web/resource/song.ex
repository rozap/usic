defmodule Usic.Resource.Song do
  import Ecto.Query
  require Logger
  import Usic.Resource.Helpers
  alias Usic.Loader
  alias Usic.Song
  alias Usic.Model.Dispatcher
  alias Usic.Repo
  alias Usic.Resource.State


  def join_user do
    from(s in Song,
      left_join: u in assoc(s, :user),
      left_join: r in assoc(s, :regions)
    )
  end

  def check_user_perms(song, session) do
    current_uid = case session do
      nil -> nil
      _ -> session.user_id
    end

    case song do
      %Song{id: nil} -> [] #nascent song can be updated always
      %Song{user_id: nil} -> [] #anyone can update an anon song
      %Song{user_id: ^current_uid} -> [] #same user can update own
      _ -> %{user_id: "song_update_not_allowed"}
    end
  end

  def validate(_, %State{resp: song, socket: socket} = state) do
    session = get_in(socket.assigns, [:session])
    case check_user_perms(song, session) do
      [] ->
        state
      errors ->
        struct(state, error: errors)
    end
  end

  defimpl Usic.Resource.Read, for: Song do
    def handle(_, %State{params: %{"id" => id}} = state) do
      model = Usic.Resource.Song.join_user
      |> where([s], s.id == ^id)
      |> group_by([s], s.id)
      |> select([s], s)
      |> Repo.one

      case model do
        nil ->
          struct(state, error: %{id: :not_found})
        _ ->
          result = model
          |> Repo.preload(:user)
          |> Repo.preload(:regions)

          struct(state, resp: result)
      end

    end
  end

  defimpl Usic.Resource.List, for: Song do

    def pop_where(%{"where" => where} = params, name) do
      put_in(params, ["where"], Map.delete(where, name))
    end

    def query(q, %{"where" => %{"name" => term}} = params) do
      query_term = "%#{term}%"
      q
      |> where([s], ilike(s.name, ^query_term))
      |> query(pop_where(params, "name"))
    end

    def query(q, %{"where" => %{"regions" => tags}} = params) do
      q
      |> where([s, u, r], fragment("?->'tags' \\?| ?", r.meta, ^tags))
      |> query(pop_where(params, "regions"))
    end

    def query(q, params), do: apply_filters(q, params)

    def handle(_, %State{params: params} = state) do
      q = Usic.Resource.Song.join_user
      |> query(params)

      result = q
      |> group_by([s], s.id)
      |> slice(params)
      |> select([s], s)
      |> eval_q

      songs = with {:ok, songs} <- result do
        {:ok, songs
        |> Repo.preload(:user)
        |> Repo.preload(:regions)}
      end

      enum_meta(q, songs, state)
    end
  end

  defimpl Usic.Resource.Create, for: Song do
    use Usic.Resource

    stage :put_user
    stage :create, mod: Usic.Resource.CreateAny
    stage :begin_download
    stage :handle, mod: Usic.Resource.Read

    def put_user(_, %State{params: params, socket: %{assigns: %{session: session}}} = state) do
      params = Dict.put(params, "user_id", session.user.id)
      struct(state, params: params)
    end
    def put_user(_, state), do: state

    def begin_download(_, %State{resp: song, socket: socket} = state) do
      Dispatcher.bind(song, socket)
      Loader.get_song(song)
      state
    end
  end

  defimpl Usic.Resource.Update, for: Song do
    use Usic.Resource
    stage :handle,   mod: Usic.Resource.Read
    stage :validate, mod: Usic.Resource.Song
    stage :update,   mod: Usic.Resource.UpdateAny
    stage :handle,   mod: Usic.Resource.Read
  end

  defimpl Usic.Resource.Delete, for: Song do
    use Usic.Resource
    stage :handle,   mod: Usic.Resource.Read
    stage :validate, mod: Usic.Resource.Song
    stage :delete,   mod: Usic.Resource.DeleteAny
  end
end
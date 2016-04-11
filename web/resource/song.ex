defmodule Usic.Resource.Song do
  import Ecto.Query
  require Logger
  import Usic.Resource.Helpers
  alias Usic.Loader
  alias Usic.Song
  alias Usic.Model.Dispatcher
  alias Usic.Resource.State


  def join_user do
    from(m in Song,
      left_join: u in assoc(m, :user),
      preload: [user: u])
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
    def handle(_, %State{params: params} = state) do
      Usic.Resource.Song.join_user
      |> as_single_result_for(%Song{}, params, state)
    end
  end

  defimpl Usic.Resource.List, for: Song do
    def handle(_, %State{params: params} = state) do
      Usic.Resource.Song.join_user
      |> slice(params)
      |> select([m], m)
      |> as_list_result_for(%Song{}, state)
    end
  end

  defimpl Usic.Resource.Create, for: Song do
    use Usic.Resource

    stage :put_user
    stage :create, mod: Usic.Resource.CreateAny
    stage :begin_download
    # stage :handle, mod: Usic.Resource.Read

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
  end

  defimpl Usic.Resource.Delete, for: Song do
    use Usic.Resource
    stage :handle,   mod: Usic.Resource.Read
    stage :validate, mod: Usic.Resource.Song
    stage :delete,   mod: Usic.Resource.DeleteAny
  end
end
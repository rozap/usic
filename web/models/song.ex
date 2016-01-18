defmodule Usic.SongState do
  defstruct [
    clicks:      [],
    measures:    [],
    load_state:  "loading",
    error:       nil,
    rate:        1,
    pxPerSecond: 40,
    autoCenter:  false
  ]

  defmodule Type do
    @behaviour Ecto.Type
    alias Usic.SongState

    def type, do: :json

    def cast(%SongState{} = state) do
      {:ok, state}
    end
    def cast(%{} = state)      do
      state = state
      |> Enum.map(fn
        {key, val} when is_atom(key) -> {key, val}
        {key, val} -> {String.to_atom(key), val}
      end)
      |> Enum.into(%{})
      {:ok, struct(SongState, state)}
    end
    def cast(_other),           do: :error

    def load(value) do
      Poison.decode(value, as: SongState)
    end

    def dump(value) do
      Poison.encode(value)
    end
  end
end

defmodule Usic.Song do
  use Ecto.Model
  use Ecto.Model.Callbacks
  alias Usic.User
  require Usic.SongState
  require Logger
  alias Usic.SongState
  alias Usic.Song

  @wtf %{
    clicks:      [],
    measures:    [],
    load_state:  "loading",
    error:       nil,
    rate:        1,
    pxPerSecond: 40,
    autoCenter:  false
  }

  after_insert Usic.Model.Dispatcher, :after_insert
  after_update Usic.Model.Dispatcher, :after_update

  schema "song" do
    field :name, :string, default: "untitled"
    field :url, :string
    field :uid, :string
    field :location, :string
    field :state, SongState.Type, default: @wtf
    belongs_to :user, User
    has_many :regions, Usic.Region, on_delete: :delete_all
    timestamps
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
      _ -> [user_id: "song_update_not_allowed"]
    end
  end

  defp validate_user(cset, song, session) do
    check_user_perms(song, session)
    |> Enum.reduce(cset, fn {key, err}, acc -> add_error(cset, key, err) end)
  end

  defp validate_url(:url, url) do
    case Usic.Loader.get_song_id(url) do
      {:error, reason} -> [url: reason]
      _ -> []
    end
  end

  def changeset(song, params \\ :empty, session: session) do
    params = case session do
      nil -> Dict.put(params, "user_id", nil)
      _ -> Dict.put(params, "user_id", session.user.id)
    end

    cast(song, params, ~w(url), ~w(name user_id location state))
    |> validate_change(:url, &validate_url/2)
    |> validate_user(song, session)
  end
end

defimpl Poison.Encoder, for: Usic.Song do
  @attributes ~w(id name url inserted_at updated_at user state location)a

  def encode(song, _options) do
    song
    |> Map.take(@attributes)
    |> Poison.encode!
  end
end
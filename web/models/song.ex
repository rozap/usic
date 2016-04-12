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
    alias Usic.Util

    def type, do: :map

    def cast(%SongState{} = state) do
      {:ok, state}
    end
    def cast(%{} = state)      do
      {:ok, struct(SongState, Util.to_atom_map(state))}
    end
    def cast(_), do: :error
    def load(value), do: {:ok, value}
    def dump(value), do: {:ok, value}
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

  schema "song" do
    field :name, :string, default: "untitled"
    field :url, :string
    field :uid, :string
    field :location, :string
    field :state, SongState.Type, default: %SongState{}
    belongs_to :user, User
    has_many :regions, Usic.Region, on_delete: :delete_all
    timestamps
  end


  defp validate_url(:url, url) do
    case Usic.Loader.get_song_id(url) do
      {:error, reason} -> [url: reason]
      _ -> []
    end
  end

  def changeset(song, params \\ :empty) do
    cast(song, params, ~w(url), ~w(name user_id location state))
    |> validate_change(:url, &validate_url/2)
  end
end

defimpl Poison.Encoder, for: Usic.Song do
  @attributes ~w(id name url inserted_at updated_at user state location regions)a

  def encode(song, _options) do
    song
    |> Map.take(@attributes)
    |> Poison.encode!
  end
end
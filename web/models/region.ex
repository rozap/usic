defmodule Usic.Region.Meta do
  defstruct [
    tags:      []
  ]

  defmodule Type do
    @behaviour Ecto.Type
    alias Usic.Region.Meta

    def type, do: :jsonb

    def cast(%Meta{} = state), do: {:ok, state}
    def cast(_other),           do: :error

    def load(value) do
      Poison.decode(value, as: Usic.Region.Meta)
    end

    def dump(value) do
      Poison.encode(value)
    end
  end
end


defmodule Usic.Region do
  use Ecto.Model
  alias Usic.Song
  alias Usic.Region.Meta

  schema "region" do
    field :name,  :string
    field :start, :float
    field :end,   :float
    field :loop,  :boolean
    field :meta,  Meta.Type, default: %{}

    belongs_to :song, Song
    timestamps
  end


  def check_user_perms(song_id, session) do
    # IO.inspect Usic.Repo.get(region.song)
    case Usic.Repo.get(Song, song_id) do
      nil -> []
      song -> Song.check_user_perms(song, session)
    end
  end

  defp validate_user(cset, song_id, session) do
    check_user_perms(song_id, session)
    |> Enum.reduce(cset, fn {key, err}, acc -> add_error(cset, key, err) end)
  end

  def changeset(region, params \\ :empty, session: session) do
    meta = case params["name"] do
      name -> 
        tags = name 
        |> String.split(" ") 
        |> Enum.filter(fn "#" <> _ -> true; _ -> false end)
        |> Enum.map(fn "#" <> t -> t end)

        %Meta{tags: tags}
      _ -> region.meta
    end
    params = Dict.put(params, "meta", meta)
    cast(region, params, ~w(song_id name start end loop meta))
    |> validate_user(params["song_id"], session)
  end
end


defimpl Poison.Encoder, for: Usic.Region do
  @attributes ~w(id name start end loop song_id inserted_at updated_at meta)a

  def encode(song, _options) do
    song
    |> Map.take(@attributes)
    |> Poison.encode!
  end
end
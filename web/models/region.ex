defmodule Usic.Region do
  use Ecto.Model
  alias Usic.Song

  schema "region" do
    field :name,  :string
    field :start, :float
    field :end,   :float
    field :loop,  :boolean

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
    cast(region, params, ~w(song_id name start end loop))
    |> validate_user(params["song_id"], session)
  end
end


defimpl Poison.Encoder, for: Usic.Region do
  @attributes ~w(id name start end loop song_id inserted_at updated_at)a

  def encode(song, _options) do
    song
    |> Map.take(@attributes)
    |> Poison.encode!
  end
end
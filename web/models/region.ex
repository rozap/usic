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

  def changeset(region, params \\ :empty, opts \\ []) do
    cast(region, params, ~w(song_id name start end loop))
  end
end


defimpl Poison.Encoder, for: Usic.Region do
  @attributes ~w(id name start end loop song_id inserted_at updated_at)a

  def encode(song, _options) do
    song
    |> Map.take(@attributes)
    |> Map.drop([:__meta__])
    |> Poison.encode!
  end
end
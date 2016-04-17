defmodule Usic.Region.Meta do
  defstruct [
    tags: []
  ]

  defmodule Type do
    @behaviour Ecto.Type
    alias Usic.Region.Meta
    alias Usic.Util

    def type, do: :map

    def cast(%Meta{} = state), do: {:ok, state}
    def cast(state), do: {:ok, struct(Meta, Util.to_atom_map(state))}
    def load(value), do: {:ok, value}
    def dump(value), do: {:ok, value}
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
    field :meta,  Meta.Type, default: %Meta{}

    belongs_to :song, Song
    timestamps
  end


  def changeset(region, params \\ :empty) do
    meta = case params["name"] do
      nil -> region.meta
      name ->
        tags = name
        |> String.split(" ")
        |> Enum.filter(fn "#" <> _ -> true; _ -> false end)
        |> Enum.map(fn "#" <> t -> String.strip(t) end)

        %Meta{tags: tags}
    end
    params = Dict.put(params, "meta", meta)
    cast(region, params, ~w(song_id name start end loop meta), [])
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
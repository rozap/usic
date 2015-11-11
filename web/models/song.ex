defmodule Usic.Song do
  use Ecto.Model
  alias Usic.User

  @whitelist [:id, :name, :url]

  schema "song" do
    field :name, :string
    field :url, :string
    belongs_to :user, User, references: :email, type: :string, foreign_key: :user, define_field: false
    timestamps
  end

  def changeset(song, params \\ :empty, user: user) do
    params = case user do
      nil -> Dict.put(params, "user", nil)
      _ -> Dict.put(params, "user", user.email)
    end
    song |> cast(params, ~w(name url))
  end
end

defimpl Poison.Encoder, for: Usic.Song do
  @attributes ~w(id name url inserted_at updated_at)a

  def encode(song, _options) do
    song
    |> Map.take(@attributes)
    |> Poison.encode!
  end
end
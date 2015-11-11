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

  ##
  # this is stupid but it's simple
  def readable(instance) do
    Usic.Model.Util.sanitize(instance, @whitelist)
  end

end

defimpl Poison.Encoder, for: Usic.Song do
  @attributes ~W(id name url inserted_at updated_at)

  def encode(song, _options) do
    song
    |> Map.take(@attributes)
    |> Poison.encode!
  end
end
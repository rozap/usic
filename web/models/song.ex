defmodule Usic.Song.State do
  defstruct [
    clicks:          [],
  ]

  defmodule Type do
    @behaviour Ecto.Type
    alias Usic.Song.State

    def type, do: :json

    def cast(%State{} = state), do: {:ok, state}
    def cast(%{} = state),         do: {:ok, struct(State, state)}
    def cast(_other),                 do: :error

    def load(value), do: Poison.decode(value, as: Usic.Song.State)

    def dump(value), do: Poison.encode(value)
  end
end

defmodule Usic.Song do
  use Ecto.Model
  alias Usic.User

  @whitelist [:id, :name, :url]

  schema "song" do
    field :name, :string
    field :url, :string
    field :uid, :string
    field :location, :string
    field :state, Usic.Song.State.Type
    belongs_to :user, User
    timestamps
  end

  def changeset(song, params \\ :empty, session: session) do
    params = case session do
      nil -> Dict.put(params, "user_id", nil)
      _ -> Dict.put(params, "user_id", session.user.id)
    end
    cast(song, params, ~w(name url), ~w(user_id))
  end




end

defimpl Poison.Encoder, for: Usic.Song do
  @attributes ~w(id name url inserted_at updated_at user_id state)a

  def encode(song, _options) do
    song
    |> Map.take(@attributes)
    |> Poison.encode!
  end
end
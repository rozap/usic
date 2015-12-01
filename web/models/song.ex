defmodule Usic.Song.State do
  defstruct [
    clicks:      [],
    load_state:  "load_start",
    error:       nil,
    rate:        1,
    pxPerSecond: 40,
    autoCenter:  false
  ]

  defmodule Type do
    @behaviour Ecto.Type
    alias Usic.Song.State

    def type, do: :json

    def cast(%State{} = state) do
      {:ok, state}
    end
    def cast(%{} = state)      do
      IO.puts "DOING CAST STATE"
      {:ok, struct(State, state)}
    end
    def cast(_other),           do: :error

    def load(value) do
      Poison.decode(value, as: Usic.Song.State)
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
  alias Usic.Song.State

  after_insert Usic.Model.Dispatcher, :after_insert
  after_update Usic.Model.Dispatcher, :after_update

  schema "song" do
    field :name, :string, default: "untitled"
    field :url, :string
    field :uid, :string
    field :location, :string
    field :state, State.Type, default: %State{}
    belongs_to :user, User
    timestamps
  end


  def changeset(song, params \\ :empty, session: session) do
    params = case session do
      nil -> Dict.put(params, "user_id", nil)
      _ -> Dict.put(params, "user_id", session.user.id)
    end
    IO.puts "CHANGESET FOR #{inspect song} \n\n #{inspect params}"
    cast(song, params, ~w(url), ~w(name user_id location state))
    |> validate_change(:url, fn
        :url, url -> []
      end)
  end




end

defimpl Poison.Encoder, for: Usic.Song do
  @attributes ~w(id name url inserted_at updated_at user_id state location)a

  def encode(song, _options) do
    song
    |> Map.take(@attributes)
    |> Poison.encode!
  end
end